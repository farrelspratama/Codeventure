class_name Level extends Node

@onready var game: Node2D = $"."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game.y_sort_enabled = true
	PlayerManager.set_as_parent(game)
	
	if not LevelManager.level_load_started.is_connected(_free_level):
		LevelManager.level_load_started.connect(_free_level)
	
	UIManager.register_ui(
		get_node("/root/PauseMenu"),
		get_node("/root/InventoryMenu"),
		get_node("/root/CharacterMenu"),
		get_node("/root/Dialog")
	)


func _free_level() -> void:
	UIManager.close_current_ui()
	
	PlayerManager.unparent_player(game)
	queue_free()
