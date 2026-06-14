class_name Spike
extends Area2D
@export_category("Ingame propierties")
@export var damage: float = 25
@export var is_active: bool = false

func _on_body_entered(body):
	if body is Character:
		var damage_done = damage
		body.global_position = body.checkpoint_position
		#if not body.invulnerable:
		body.take_damage(damage_done)
		print("Toco pinchos")
		print(body.life)
