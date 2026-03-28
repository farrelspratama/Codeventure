@tool
class_name TreasureChest extends Node2D

@export var item_data : ItemData : set = _set_item_data
@export var data : InventoryData

var is_open: bool = false
var player_in_range: bool = false

@onready var area_2d: Area2D = $Area2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	area_2d.area_entered.connect(_on_area_entered)
	area_2d.area_exited.connect(_on_area_exited)


func _process(_delta) -> void:
	if player_in_range and Input.is_action_just_pressed("test"):
		player_interact()


func player_interact() -> void:
	if is_open:
		return
	
	is_open = true
	print("Chest opened")
	animation_player.play("open_chest")
	data.add_item()

func _set_item_data(value : ItemData) -> void:
	item_data = value

func _on_area_entered(area: Area2D) -> void:
	if area.get_parent().get_parent() is Player:
		player_in_range = true
		print("Player near chest")


func _on_area_exited(area: Area2D) -> void:
	if area.get_parent().get_parent() is Player:
		player_in_range = false
		print("Player left chest")
