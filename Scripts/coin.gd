class_name Coin
extends Area2D

@export var points: int = 500

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D if has_node("AnimatedSprite2D") else null

func _ready() -> void:
	anim.play("idle")

func _on_body_entered(body):
	if body is Character:
		body.puntaje += points
		anim.play("collected")
		anim.offset = Vector2(0,-32)
		body.checkpoint_position = global_position
		anim.speed_scale = 2.0
		print("Checkpoint Guardado")
		print(body.puntaje)
		await anim.animation_finished
		queue_free()
