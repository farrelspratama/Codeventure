@tool
class_name TreasureChest extends Node2D

@export var item_data : ItemData : set = _set_item_data

var is_open: bool = false
var player_in_range: bool = false

@onready var area_2d: Area2D = $Area2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var is_open_data: PersistentDataHandler = $IsOpen

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	area_2d.area_entered.connect(_on_area_entered)
	area_2d.area_exited.connect(_on_area_exited)
	
	is_open_data.data_loaded.connect(set_chest_state)
	set_chest_state()


func _process(_delta) -> void:
	if player_in_range and Input.is_action_just_pressed("interact"):
		player_interact()


func player_interact() -> void:
	if is_open:
		return
	
	is_open = true
	is_open_data.set_value()
	print("Chest opened")
	animation_player.play("open_chest")
	
	PlayerManager.INVENTORY_DATA.add_item(item_data)

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

func set_chest_state() -> void:
	is_open = is_open_data.value
	if is_open:
		animation_player.play("open_chest")
	else:
		animation_player.play("RESET")
