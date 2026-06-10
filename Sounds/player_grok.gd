class_name Player
extends CharacterBody2D

# ==================== CONSTANTES ====================
const SPEED = 130.0
const JUMP_VELOCITY = -250.0
const COYOTE_TIME = 0.15
const KNOCKBACK_FORCE = 200
const HURT_KNOCKBACK_Y = -150

# ==================== VARIABLES ====================
var health: int = 6
var collectibles: int = 0

var coyote_timer: float = 0.0
var is_attacking: bool = false
var is_hurt: bool = false
var invulnerable: bool = false

var checkpoint_position: Vector2

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

# ==================== SEÑALES ====================
signal health_changed(new_health: int)
signal player_died()
signal collectible_collected(total: int)

func _ready() -> void:
	checkpoint_position = global_position
	anim.animation_finished.connect(_on_animation_finished)


func _physics_process(delta: float) -> void:
	# Si está herido, solo aplicamos física (knockback)
	if is_hurt:
		move_and_slide()
		return
	
	# Gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Coyote Time
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer -= delta
	
	# Ataque
	if Input.is_action_just_pressed("attack") and is_on_floor() and not is_attacking:
		start_attack()
		return
	
	# Salto normal
	if Input.is_action_just_pressed("ui_accept") and coyote_timer > 0:
		velocity.y = JUMP_VELOCITY
		coyote_timer = 0
	
	# Movimiento horizontal
	var direction = Input.get_axis("ui_left", "ui_right")
	
	if direction != 0:
		velocity.x = direction * SPEED
		anim.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# Animaciones
	update_animations(direction)
	
	move_and_slide()


func start_attack() -> void:
	is_attacking = true
	velocity.x = 0
	anim.play("Attack")


func update_animations(direction: float) -> void:
	if not is_on_floor():
		if velocity.y < 0:
			anim.play("Jump")
		else:
			anim.play("Fall")
	else:
		if direction != 0:
			anim.play("Walk")
		else:
			anim.play("Idle")


func _on_animation_finished() -> void:
	if anim.animation == "Attack":
		is_attacking = false
	elif anim.animation == "Damage":
		is_hurt = false


# ==================== DAÑO ====================
func take_damage(enemy_position_x: float) -> void:
	if invulnerable or is_hurt:
		return
	
	health -= 1
	health_changed.emit(health)
	
	if health <= 0:
		die()
		return
	
	is_hurt = true
	invulnerable = true
	anim.play("Damage")
	
	# Knockback
	velocity.y = HURT_KNOCKBACK_Y
	velocity.x = KNOCKBACK_FORCE if global_position.x < enemy_position_x else -KNOCKBACK_FORCE
	
	await get_tree().create_timer(1.0).timeout
	invulnerable = false


func take_damage_environment() -> void:
	if invulnerable:
		return
	
	health -= 2
	health_changed.emit(health)
	print(health)
	
	if health <= 0:
		is_hurt = true
		print(health)
		die()
		return
	
	invulnerable = true
	start_blinking()
	await get_tree().create_timer(0.5).timeout
	invulnerable = false
	stop_blinking()

# ==================== EFECTO PARPADEO ====================
func start_blinking() -> void:
# Creamos un timer para el parpadeo
	var blink_timer = get_tree().create_timer(0.1)
	var times = 5  # Cuántas veces parpadeará (ajustable)
	for i in range(times):
		anim.modulate.a = 0.3   # Casi transparente
		await get_tree().create_timer(0.1).timeout
		anim.modulate.a = 1.0   # Normal
		await get_tree().create_timer(0.1).timeout
		
func stop_blinking() -> void:
	anim.modulate.a = 1.0

func die() -> void:
	player_died.emit()
	anim.play("Death")
	await get_tree().create_timer(1.2).timeout
	anim.play("Spirit")
	set_physics_process(false)  # Detiene el movimiento
	# Aquí luego puedes poner animación de muerte
