extends CanvasLayer

signal shown
signal hidden

@onready var tab_container: TabContainer = $Control/TabContainer

func _ready() -> void:
	hide_menu()

func show_menu():
	tab_container.current_tab = 0
	visible = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	shown.emit()

func hide_menu():
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().paused = false
	hidden.emit()
