class_name Mummy
extends CharacterBody2D

@export var velocidad: float = 60.0

# 1 significa derecha, -1 significa izquierda
var direccion = 1 
var deathPlayed: bool
const DAMAGE: float = 12.50
var life: int = 0
var is_invulnerable:bool = false
var gravedad: float = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var player = get_tree().get_first_node_in_group("player")
var is_knocked_back: bool = false
var knockback_timer: float = 0.0

@onready var detector_piso = $RayCast2D
@onready var anim = $AnimatedSprite2D
@onready var track_area = $track_player
@onready var hitbox: CollisionShape2D = $Hitbox/HitboxCollision
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	life = 4

func _physics_process(delta: float) -> void:
	# 1. Gravedad 
	if not is_on_floor():
		velocity.y += gravedad * delta
	
		
		
	if life == 0:
		hitbox.disabled = true
		collision.disabled = true
		velocity.y = 0
		velocity.x = 0
		if not deathPlayed:
			anim.play("death")
			await  anim.animation_finished
			deathPlayed = true
		anim.play("dead")
		await  get_tree().create_timer(2).timeout
		queue_free()
	else:
	# 2. Lógica de darse la vuelta
	# is_colliding() revisa si el RayCast está tocando el piso.
	# Si toca una pared O si el RayCast ya no detecta piso... ¡Da la vuelta!
		if is_on_wall() or not detector_piso.is_colliding():
			direccion *= -1 # Invertimos la dirección matemática (de 1 a -1, o de -1 a 1)
			anim.flip_h = (direccion == -1)
			# Movemos el RayCast para que siempre esté al frente de la cara del enemigo
			# (Cambia el 15 por la distancia que necesites según el ancho del enemy)
			detector_piso.position.x = 6  *  direccion
			track_area.scale.x = direccion

		# 3. Caminar siempre hacia adelante
		if is_knocked_back:
			knockback_timer -= delta
			anim.play("damaged")
			if knockback_timer <= 0:
				is_knocked_back = false
				anim.play("walk")
		else:
			velocity.x = direccion * velocidad
	
	move_and_slide()
	
	
		


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is Character:
		var damage_done = DAMAGE
		await get_tree().create_timer(0.02).timeout
		body.global_position = body.checkpoint_position
		#if not body.invulnerable:
		body.take_damage(damage_done)
		print("Mommia Toco")


func _on_track_body_entered(body: Node2D) -> void:
	if body is Character:
		anim.play("chase")
		velocidad = 100
		
		


func _on_track_body_exited(body: Node2D) -> void:
	if body is Character:
		anim.play("walk") 
		velocidad = 60

"""func take_damage(damage:int):
	position.x = position.x + (20 * direccion)
	if not is_invulnerable and life > 0:	
		if damage > life:
			life = 0
		else:
			life -= damage
			print(life)
			is_invulnerable = true
			await get_tree().create_timer(0.7)
			is_invulnerable = false
"""
func take_damage(damage: int):
	# === KNOCKBACK basado en posición del jugador ===
	if player:  # por si acaso el player no está disponible
		var knockback_direction = sign(global_position.x - player.global_position.x)
		
		# Si el jugador está a la izquierda → knockback a la derecha (positivo)
		# Si el jugador está a la derecha  → knockback a la izquierda (negativo)
		var knockback_force = 50   # Ajusta este valor según sientas (prueba 60~120)
		
		# Aplicamos el knockback (mejor usar velocity que position)
		
		# Pequeño impulso vertical opcional (queda más "golpeado")
		# velocity.y = -80

	# === DAÑO ===
		if not is_invulnerable and life > 0:
			velocity.x = knockback_direction * knockback_force
			is_knocked_back = true
			knockback_timer = 0.5
			if damage > life:
				life = 0
			else:
				life -= damage
				print("Mummy life: ", life)
				
				is_invulnerable = true
				anim.modulate = Color(1, 0.5, 0.5)  # Feedback visual (rojo)
				
				await get_tree().create_timer(0.6).timeout
				
				is_invulnerable = false
				anim.modulate = Color(1, 1, 1)

func get_knockback(knockbackDirection, knockbackForce):
	knockbackDirection *= -1
	await get_tree().create_timer(0.1).timeout

func _on_hurt_box_area_entered(area: Area2D) -> void:
	if area.name == "WhipHitbox":
		take_damage(1)
		print("That hurt")
