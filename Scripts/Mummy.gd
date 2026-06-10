class_name Mummy
extends CharacterBody2D

@export var velocidad: float = 60.0
var gravedad: float = ProjectSettings.get_setting("physics/2d/default_gravity")

# 1 significa derecha, -1 significa izquierda
var direccion = 1 

@onready var detector_piso = $RayCast2D
@onready var anim = $AnimatedSprite2D
@onready var track_area = $track_player
const DAMAGE: int = 1

func _physics_process(delta: float) -> void:
	# 1. Gravedad 
	if not is_on_floor():
		velocity.y += gravedad * delta
		
	# 2. Lógica de darse la vuelta
	# is_colliding() revisa si el RayCast está tocando el piso.
	# Si toca una pared O si el RayCast ya no detecta piso... ¡Da la vuelta!
	if is_on_wall() or not detector_piso.is_colliding():
		direccion *= -1 # Invertimos la dirección matemática (de 1 a -1, o de -1 a 1)
		anim.flip_h = (direccion == -1)
		# Movemos el RayCast para que siempre esté al frente de la cara del enemigo
		# (Cambia el 15 por la distancia que necesites según el ancho del enemy)
		detector_piso.position.x = 6  *  direccion
		if direccion == -1:
			track_area.rotation_degrees = 180.00
		else:
			track_area.rotation_degrees = 0.00
		

	# 3. Caminar siempre hacia adelante
	velocity.x = direccion * velocidad
	
	move_and_slide()


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is Character:
		await get_tree().create_timer(0.02).timeout
		body.global_position = body.checkpoint_position
		#if not body.invulnerable:
		body.take_damage(DAMAGE)
		print("Mommia Toco")


func _on_track_body_entered(body: Node2D) -> void:
	if body is Character:
		anim.play("chase")
		velocidad = 100
		
		


func _on_track_body_exited(body: Node2D) -> void:
	if body is Character:
		anim.play("walk") 
		velocidad = 60
