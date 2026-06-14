class_name Character
extends CharacterBody2D

const COYOTE_TIME: float = 0.12
const START_LIFE: int = 100
# @export = es para hacer aparecer la caraceristica en el inspector
@export_category("Configuración de Movimiento")
@export var velocidad: float = 130.0
@export var fuerza_salto: float = -250.0
@export_category("Datos del Jugador")
@export var life: float = 0
@export var puntaje: int = 0
@export var coyote_timer: float = 0.0
# Diccionario para rastrear gemas clave (usado en el Lobby)
@export var CollectedKeyGems: Dictionary = {
	"Amethyst": false,
	"Ruby": false,
	"Emerald": false,
	"Diamond": false
}

@onready var anim = $AnimatedSprite2D
@onready var whip_hitbox = $WhipHitbox
@onready var whip_collision = $WhipHitbox/CollisionShape2D
@onready var whip_sprite = $WhipHitbox/Sprite2D
@onready var canvas_modulate: CanvasModulate = $CanvasModulate
@onready var health_bar: TextureProgressBar = $CanvasLayer/TextureProgressBar
@onready var gem_progress: TextureProgressBar = $CanvasLayer/gem_progress

var invulnerable = false
var gravedad: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_attacking = false
var checkpoint_position: Vector2
var pushable_is_near: bool = false
var is_damaged: bool = false
#Metodos
func _ready() -> void:
	checkpoint_position = global_position
	anim.play("Idle")
	life = START_LIFE
	health_bar.value = life
	gem_progress.value = 0

func _physics_process(delta: float) -> void:
	# 1. Aplicar la Gravedad (Siempre se aplica, incluso atacando)
	if not is_on_floor():
		velocity.y += gravedad * delta
		
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer -= delta
	
	# 2. Lógica de Ataque
	if Input.is_action_just_pressed("attack") and is_on_floor() and not is_attacking:
		is_attacking = true
		anim.play("Attack")
		velocity.x = 0
		
		await get_tree().create_timer(0.15).timeout
		whip_collision.disabled = false
		whip_sprite.visible = true
		
		await get_tree().create_timer(0.06).timeout
		whip_collision.disabled = true
		whip_sprite.visible = false
		
		# Esperamos a que la animación termine para soltar al personaje
		await anim.animation_finished
		is_attacking = false
	
	# Si está atacando, solo lo dejamos caer por gravedad y cortamos el script aquí
	if is_attacking:
		move_and_slide()
		return

	# 3. Saltar
	if Input.is_action_just_pressed("ui_accept") and coyote_timer > 0:
		velocity.y = fuerza_salto
		coyote_timer = 0

	# 4. Movimiento Horizontal y Rotación de Sprite
	var direccion := Input.get_axis("ui_left", "ui_right")
	
	if direccion != 0:
		velocity.x = direccion * velocidad
		anim.flip_h = direccion < 0
		whip_hitbox.scale.x = -1 if direccion < 0 else 1
	else:
		velocity.x = move_toward(velocity.x, 0, velocidad)

	# 5. Manejo de Animaciones
	if is_on_floor():
		if direccion == 0:
			anim.play("Idle")
		else:
			anim.play("Walk")
	else:
		if velocity.y < 0:
			anim.play("Jump")
		else:
			anim.play("Fall")
	
	if Input.is_action_pressed("interact"):
		anim.play("Active")
		velocity.x = 0
	if pushable_is_near and Input.is_action_pressed("push") and direccion != 0:
		anim.play("push")
	# 6. Ejecutar el movimiento
	if life == 0:
		anim.play("Death")
		await anim.animation_finished
		anim.play("Spirit")
		velocity.y -= 1
	
	move_and_slide()

func take_damage(dano:float):
	if not invulnerable:	
		if dano > life:
			life = 0
		else:
			life -= dano
			health_bar.value = life
			print(life)
			invulnerable = true
			await get_tree().create_timer(0.5)
			invulnerable = false
		if life == 0:
			print("Has muerto")
			get_tree().reload_current_scene()
	
func win() -> void:
	anim.play("win")
	await anim.animation_finished

func _on_push_area_body_entered(body: Node2D) -> void:
	#if body.is_on_group("Pushable")
	pass # Replace with function body.\
	
