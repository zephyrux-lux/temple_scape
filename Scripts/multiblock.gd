class_name MultiBlock
extends StaticBody2D

#Region Declaracion de Variables
@export_category('Puzzle Protpierties')
@export var is_required: bool = false
@export var on_step: int = 0
@export var is_dropper: bool = false

@export_category("Dropper Settings")
@export var item_to_drop: PackedScene #Escena del objeto a soltar
@export var drop_force: float = 100
@export var drop_offset: Vector2 = Vector2 (0, 64)

@onready var funtion = $AnimatedSprite2D

var was_active: bool = false
#EndRegion

signal item_dropped(item: Node2D)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_role(0)

func set_role(role):
	match role:
		1:
			funtion.play("face1")
			on_step = 1
			is_required = true
		2:
			funtion.play("face2")
			on_step = 2
			is_required = true
		3:
			funtion.play("face3")
			on_step = 3
			is_required = true
		4:
			funtion.play("face4")
			on_step = 4
			is_required = true
		5:
			funtion.play("dropper")
			was_active = true
		6:
			funtion.play("ring")
			was_active = false
			is_required = false
		0:
			funtion.play("disabled")
			on_step = 0
			
			
		
