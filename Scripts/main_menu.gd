extends Node2D

@onready var big_door: AnimatedSprite2D = $big_door
@onready var animationP: AnimationPlayer = $animation/AnimationPlayer2
@onready var animation: Node2D = $animation

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation.sprite.play("idle")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_pressed() -> void:
	animation.sprite.play("walk")
	animationP.play("new_animation")
	await animationP.animation_finished
	get_tree().change_scene_to_file("res://Scenes/lobby.tscn")


func _on_option_pressed() -> void:
	get_tree().change_scene_to_file("")


func _on_quit_pressed() -> void:
	get_tree().quit()
