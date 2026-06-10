class_name Spike
extends Area2D
@export_category("Ingame propierties")
@export var damage_dealt : int = 2
@export var is_active: bool = false

func _on_body_entered(body):
	if body is Character:
		await get_tree().create_timer(0.05).timeout
		body.global_position = body.checkpoint_position
		#if not body.invulnerable:
		body.take_damage(2)
		print("Toco pinchos")
