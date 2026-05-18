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

# --- FUNGSI BANTUAN BARU ---
# Mengecek apakah ada event penting yang sedang menghalangi UI utama
func _is_system_busy() -> bool:
	if dialog != null and dialog.is_active:
		return true
	if DragNDrop != null and DragNDrop.is_active:
		return true
	if TextInput != null and TextInput.is_active:
		return true
	if TrueOrFalse != null and TrueOrFalse.is_active:
		return true
	if MateriUI != null and MateriUI.control.visible:
		return true
	if PopupItem != null and PopupItem.visible:
		return true
	
	return false
# ---------------------------

func open_ui(type : UIType):
	if _is_system_busy():
		return
	
	if current_ui != UIType.NONE:
		close_current_ui()
	
	current_ui = type
	
	match type:
		UIType.PAUSE:
			if pause_menu != null: # <-- Tambahkan pengaman ini
				pause_menu.show_menu()
		UIType.INVENTORY:
			if inventory_menu != null:
				inventory_menu.show_menu()
		UIType.CHARACTER:
			if character_menu != null:
				character_menu.show_menu()
	
	_update_pause_state()

func close_current_ui():
	match current_ui:
		UIType.PAUSE:
			if pause_menu != null:
				pause_menu.hide_menu()
		UIType.INVENTORY:
			if inventory_menu != null:
				inventory_menu.hide_menu()
		UIType.CHARACTER:
			if character_menu != null:
				character_menu.hide_menu()
	
	current_ui = UIType.NONE
	_update_pause_state()

func toggle_ui(type : UIType):
	if _is_system_busy():
		return
		
	if current_ui == type:
		close_current_ui()
	else:
		open_ui(type)

func handle_cancel():
	if _is_system_busy():
		return
		
	if current_ui != UIType.NONE:
		close_current_ui()
	else:
		open_ui(UIType.PAUSE)

func _unhandled_input(event):
	if _is_system_busy():
		return
		
	if event.is_action_pressed("pause"):
		handle_cancel()
	elif event.is_action_pressed("tab"):
		toggle_ui(UIType.CHARACTER)
	elif event.is_action_pressed("inventory"):
		toggle_ui(UIType.INVENTORY)

func _update_pause_state():
	get_tree().paused = current_ui != UIType.NONE
