extends Node

enum UIType {
	NONE,
	PAUSE,
	INVENTORY,
	CHARACTER
}

var current_ui : UIType = UIType.NONE

# reference ke UI
var pause_menu
var inventory_menu
var character_menu
var dialog

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	current_ui = UIType.NONE

func register_ui(_pause, _inventory, _character, _dialog):
	pause_menu = _pause
	inventory_menu = _inventory
	character_menu = _character
	dialog = _dialog

func open_ui(type : UIType):
	if dialog != null and dialog.is_active:
		return
	
	if current_ui != UIType.NONE:
		close_current_ui()
	
	current_ui = type
	
	match type:
		UIType.PAUSE:
			pause_menu.show_menu()
		UIType.INVENTORY:
			inventory_menu.show_menu()
		UIType.CHARACTER:
			character_menu.show_menu()
	
	_update_pause_state()

func close_current_ui():
	match current_ui:
		UIType.PAUSE:
			pause_menu.hide_menu()
		UIType.INVENTORY:
			inventory_menu.hide_menu()
		UIType.CHARACTER:
			character_menu.hide_menu()
	
	current_ui = UIType.NONE
	_update_pause_state()

func toggle_ui(type : UIType):
	if dialog != null and dialog.is_active:
		return
	if current_ui == type:
		close_current_ui()
	else:
		open_ui(type)

func handle_cancel():
	if dialog != null and dialog.is_active:
		return
	if current_ui != UIType.NONE:
		close_current_ui()
	else:
		open_ui(UIType.PAUSE)

func _input(event):
	if dialog != null and dialog.is_active:
		return
	if event.is_action_pressed("pause"):
		handle_cancel()
	elif event.is_action_pressed("tab"):
		toggle_ui(UIType.CHARACTER)
	elif event.is_action_pressed("inventory"):
		toggle_ui(UIType.INVENTORY)

func _update_pause_state():
	get_tree().paused = current_ui != UIType.NONE
