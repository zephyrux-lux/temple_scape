extends StaticBody2D
class_name SmallPlatform



@export_category("Propiedades")
@export var is_visible:bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	change_visibility(is_visible)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func change_visibility(view: bool) -> void:
	visible = view
	
func change_collision(layer:int) -> void:
	collision_mask = layer
	collision_layer = layer
