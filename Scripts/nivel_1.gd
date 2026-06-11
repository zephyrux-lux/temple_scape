extends Node2D

@onready var player = $Player
@onready var camera = $Player/Camera2D
@onready var lever_3: Lever = $interactive/lever3
@onready var lever_1: Lever = $interactive/lever1
@onready var lever_2: Lever = $interactive/lever2
@onready var lever_dropper: Lever = $interactive/lever_door
@onready var lever_stair: Lever = $interactive/lever_stair
@onready var face_2: MultiBlock = $map/face2
@onready var face_1: MultiBlock = $map/face1
@onready var face_3: MultiBlock = $map/face3
@onready var dropper: MultiBlock = $map/Dropper
@onready var level_door: Area2D = $"map/small-door"
@onready var exit: Area2D = $map/exit
@onready var gem_key: Amethyst = $ITem/Amethyst
@onready var gem_entry: AnimationPlayer = $ITem/Amethyst/gemEntry if $ITem/Amethyst.has_node("gemEntry") else null
var gemKeyCollected:bool = false
var puzle_step: int = 0
var correct_step: int = 0

@export_category("Puzle Configurations")
@export var last_step: int = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	camera.limit_left = 0
	camera.limit_right = 912
	camera.limit_top = 0
	camera.limit_bottom = 864
	gem_key.change_visibility(false)
	lever_stair.set_visbility(false)
	restart_puzzle()
	get_tree().call_group("plataforma_oculta","change_visibility",false)
	get_tree().call_group("plataforma_oculta","change_collision",10)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func restart_puzzle() -> void:
	face_1.set_role(1)
	face_2.set_role(2)
	face_3.set_role(3)
	lever_1.reset()
	lever_2.reset()
	lever_3.reset()
	lever_1.on_step = 1
	lever_2.on_step = 2
	lever_3.on_step = 3
	correct_step = 0
	puzle_step = 0
	level_door.is_open = false
	



func _on_lever_1_was_activated(lever: Variant) -> void:
	solving_puzle(lever, face_1)
	print(puzle_step)
	
func _on_lever_2_was_activated(lever: Variant) -> void:
	solving_puzle(lever, face_2)
	print(puzle_step)

func _on_lever_3_was_activated(lever: Variant) -> void:
	solving_puzle(lever, face_3)
	print(puzle_step)


func solving_puzle(lever, block):
	puzle_step += 1
	if lever.on_step == puzle_step:
		correct_step += 1
		block.set_role(0)
		print("Paso Correcto")
		
	if puzle_step == last_step:
		if correct_step == last_step:
			gem_key.change_visibility(true)
			gem_entry.play("solved")
			lever_stair.set_visbility(true)
		else:
			restart_puzzle()
		
		


func _on_lever_stair_was_activated(lever: Variant) -> void:
		get_tree().call_group("plataforma_oculta","change_visibility",true)
		get_tree().call_group("plataforma_oculta","change_collision",1)


func _on_lever_dropper_was_activated(lever: Variant) -> void:
	gemKeyCollected = player.CollectedKeyGems["Amethyst"]
	if gemKeyCollected:
		level_door.anim.play("open")
		await level_door.anim.animation_finished
		level_door.is_open = true
	else:
		lever_dropper.reset()


func _on_smalldoor_body_entered(body: Node2D) -> void:
	if level_door.is_open:
		print("Victory")
		get_tree().change_scene_to_file("res://Scenes/lobby.tscn")
