extends Node

const PLAYER = preload("res://system/characters/player/player.tscn")
const INVENTORY_DATA : InventoryData = preload("res://system/inventory/player_inventory.tres")

signal interact_pressed

var interact_handled : bool = true
var player : Player
var player_spawned : bool = false

func _ready() -> void:
	add_player_instance()
	await get_tree().create_timer(0.2).timeout
	player_spawned = true

func add_player_instance() -> void:
	player = PLAYER.instantiate()
	add_child(player)

func reward_score( _score : int ) -> void:
	player.score += _score
	print("Score: ", str(player.score))

func set_player_position( _new_pos : Vector2 ) -> void:
	player.global_position = _new_pos

func set_as_parent( _p : Node2D ) -> void:
	if player.get_parent():
		player.get_parent().remove_child(player)
	_p.add_child(player)

func unparent_player( _p : Node2D ) -> void:
	_p.remove_child(player)

func _input(event):
	if event.is_action_pressed("interact"):
		print("INTERACT DITEKAN")
		interact()

func interact() -> void:
	interact_handled = false
	interact_pressed.emit()
