extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -250.0
#const WALL_JUMP_VELOCITY = Vector2(200, -250)
const WALL_SLIDE_SPEED = 50.0
var collectible = 0
const COYOTE_TIME = 0.15
var coyote_timer = 0.0
var is_hurt = false
var health = 6
var invulnerable = false
var checkpoint_position: Vector2

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var is_attacking: bool = false

func _ready() -> void:
	# Conectamos la señal para saber cuándo termina el ataque
	anim.animation_finished.connect(_on_animation_finished)
	#Guardamos el Spawn point.
	checkpoint_position = global_position

func _physics_process(delta: float) -> void:
	# 1. GRAVEDAD Y WALL SLIDE
	if not is_on_floor():
		velocity += get_gravity() * delta
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer -= delta
	# 2. ATAQUE
	# NOTA: Debes ir a Project -> Project Settings -> Input Map y crear la acción "attack"
	if Input.is_action_just_pressed("attack") and is_on_floor() and not is_attacking:
		is_attacking = true
		anim.play("Attack")
		velocity.x = 0 # Detener al jugador mientras ataca

	# Si está atacando, no procesar movimiento para que no se deslice atacando
	if is_attacking:
		move_and_slide()
		return

	# 3. SALTOS (Normal y Wall Jump)
	if Input.is_action_just_pressed("ui_accept"):
		if coyote_timer > 0:
			velocity.y = JUMP_VELOCITY
			coyote_timer = 0
		'''
		elif is_on_wall_only():
			# Wall Jump (Salto de pared)
			velocity.y = WALL_JUMP_VELOCITY.y
			# Obtenemos la dirección hacia afuera de la pared
			var wall_normal = get_wall_normal()
			velocity.x = wall_normal.x * WALL_JUMP_VELOCITY.x
			# Forzamos la animación de salto de pared
			anim.play("Jump")
			'''

	# 4. MOVIMIENTO HORIZONTAL
	var direction := Input.get_axis("ui_left", "ui_right")
	
	# Solo permitimos mover libremente si no acabamos de hacer un Wall Jump 
	# (Aquí podrías agregar un pequeño timer para perder el control un milisegundo al saltar de la pared,
	# pero para simplificar, permitiremos movimiento inmediato).
	if direction:
		velocity.x = direction * SPEED
		# Voltear el sprite dependiendo de dónde mire
		anim.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# 5. ACTUALIZAR ANIMACIONES
	actualizar_animaciones(direction)

	move_and_slide()


func actualizar_animaciones(direction: float) -> void:
	# Si estamos en el aire
	if not is_on_floor():
		if is_on_wall_only() and velocity.y > 0:
			anim.play("Wall Slide")
		else:
			if velocity.y < 0:
				# Solo ponemos la animación de "Jump" si no está reproduciendo ya "Wall Jump"
				if anim.animation != "Jump":
					anim.play("Jump")
			else:
				anim.play("Fall")
	# Si estamos en el suelo
	else:
		if direction != 0:
			anim.play("Walk")
		else:
			anim.play("Idle")


func _on_animation_finished() -> void:
	# Cuando termine la animación de ataque, le devolvemos el control
	if anim.animation == "Attack":
		is_attacking = false
		
	# Cuando termine la animación de daño, le devolvemos el control
	if anim.animation == "Damage":
		is_hurt = false

func take_damage(enemy_position_x):
	
	if invulnerable:
		return
	#Iframe.
	invulnerable = true
#Recibe daño de un enemigo
	health -= 1
	is_hurt = true
	anim.play("Damage")
#AnimACION DE daño, no se puede mover
	if is_hurt:
		move_and_slide()
		return
	#Knokback
	velocity.y = -150
	if global_position.x < enemy_position_x:
		velocity.x = -200
	else:
		velocity.x = 200
	await get_tree().create_timer(1.0).timeout

func take_damage_eviroment():
	
	if invulnerable:
		return
	#Iframe.
	invulnerable = true
#Recibe daño de un enemigo
	health -= 2
	print(health)
	await get_tree().create_timer(1.0).timeout
