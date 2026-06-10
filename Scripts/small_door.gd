extends Area2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var is_open: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim.play("idle")
	is_open = false
	
	
