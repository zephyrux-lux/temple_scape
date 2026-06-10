class_name Amethyst
extends Area2D

@export_category("Propierties")
@export var is_visible: bool = true
@export var is_collected: bool = false
@export var points: int = 1000

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D if has_node("AnimatedSprite2D") else null
var me:String = "Amethyst"
# Called when the node enters the scene tree for the first time.
signal was_collected()


func _ready() -> void:
	visible = is_visible
	anim.play("idle")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body is Character:
		body.puntaje += points
		print(body.puntaje)
		is_collected = true
		body.CollectedKeyGems[me] = true
		queue_free()

func change_visibility(view):
	visible = view
