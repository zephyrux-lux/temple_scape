extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -300.0
const WALL_JUMP_VELOCITY = Vector2(200, -250)
const WALL_SLIDE_SPEED = 50.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var is_attacking: bool = false

func _ready() -> void:
	# Conectamos la señal para saber cuándo termina el ataque
	anim.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	# 1. GRAVEDAD Y WALL SLIDE
	if not is_on_floor():
		if is_on_wall_only() and velocity.y > 0:
			# Resbala por la pared más lento
			velocity += get_gravity() * delta
			velocity.y = min(velocity.y, WALL_SLIDE_SPEED)
		else:
			# Caída normal
			velocity += get_gravity() * delta

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
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif is_on_wall_only():
			# Wall Jump (Salto de pared)
			velocity.y = WALL_JUMP_VELOCITY.y
			# Obtenemos la dirección hacia afuera de la pared
			var wall_normal = get_wall_normal()
			velocity.x = wall_normal.x * WALL_JUMP_VELOCITY.x
			# Forzamos la animación de salto de pared
			anim.play("Wall Jump")

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
				if anim.animation != "Wall Jump":
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
