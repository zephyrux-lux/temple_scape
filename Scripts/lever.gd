class_name Lever
extends Area2D

@export_category('Puzzle Protpierties')
@export var is_required: bool = false
@export var on_step: int
@export var is_active: bool = false

signal was_activated(lever)

var on_range: bool = false
@onready var anim = $AnimatedSprite2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim.play("idle")
	# Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and on_range and not is_active:
		anim.play("active")
		print("Palanca activada")
		is_active = true
		was_activated.emit(self)

func _on_body_entered(body: Node2D) -> void:
	if body is Character:
		on_range = true
	
func _on_body_exited(body: Node2D) -> void:
	if body is Character:
		on_range = false

func reset() ->void:
	is_active = false
	anim.play("idle")
	
func set_visbility(view: bool) -> void:
	visible = view
	
