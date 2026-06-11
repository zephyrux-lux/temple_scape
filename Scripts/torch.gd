class_name Torch
extends AnimatedSprite2D

@onready var animation_p: AnimationPlayer = $AnimationPlayer
@onready var anim: AnimatedSprite2D = $"."
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim.play("default")
	animation_p.play("light_flick")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
