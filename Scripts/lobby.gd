class_name Lobby
extends Node2D

@onready var lever1: Lever = $levers/lever
@onready var door1: Area2D = $Doors/level1_door

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_level_1_door_body_entered(body: Node2D) -> void:
	if body is Character and door1.is_open:
		get_tree().change_scene_to_file("res://Scenes/nivel_1.tscn")
	


func _on_lever_was_activated(lever: Variant) -> void:
	door1.anim.play("open")
	await door1.anim.animation_finished
	door1.is_open = true
	pass # Replace with function body.
