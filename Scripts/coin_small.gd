class_name SmallCoin
extends Area2D

@export var points: int = 100

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D if has_node("AnimatedSprite2D") else null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	anim.play("idle")
	scale = Vector2(0.5,0.5)

func _on_body_entered(body: Node2D) -> void:
	
	if body is Character:
		body.puntaje += points
		print(body.puntaje)
		anim.play("collected")
		anim.offset = Vector2(0,-32)
		await get_tree().create_timer(0.5).timeout
		queue_free()
