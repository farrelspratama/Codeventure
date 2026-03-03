extends CanvasLayer

@onready var continue_button: Button = $Panel/VBoxContainer/ContinueButton
@onready var save_button: Button = $Panel/VBoxContainer/SaveButton
@onready var load_button: Button = $Panel/VBoxContainer/LoadButton
@onready var inventory_button: Button = $Panel/VBoxContainer/InventoryButton
@onready var main_menu_button: Button = $Panel/VBoxContainer/MainMenuButton
@onready var exit_button: Button = $Panel/VBoxContainer/ExitButton

var is_paused : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide_pause_menu()
	continue_button.pressed.connect(_on_continue_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()
		get_viewport().set_input_as_handled()

func toggle_pause() -> void:
	is_paused = !is_paused
	get_tree().paused = is_paused
	visible = is_paused

func _on_continue_pressed() -> void:
	hide_pause_menu()

func _on_exit_pressed() -> void:
	get_tree().quit()

func hide_pause_menu() -> void:
	get_tree().paused = false
	visible = false
	is_paused = false
