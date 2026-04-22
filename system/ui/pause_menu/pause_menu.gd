extends CanvasLayer

@onready var continue_button: Button = $Panel/VBoxContainer/ContinueButton
@onready var save_button: Button = $Panel/VBoxContainer/SaveButton
@onready var load_button: Button = $Panel/VBoxContainer/LoadButton
@onready var exit_button: Button = $Panel/VBoxContainer/ExitButton

func _ready() -> void:
	hide_menu()
	continue_button.pressed.connect(_on_continue_pressed)
	save_button.pressed.connect(_on_save_pressed)
	load_button.pressed.connect(_on_load_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

func show_menu():
	visible = true

func hide_menu():
	visible = false

func _on_continue_pressed():
	UIManager.close_current_ui()

func _on_save_pressed():
	SaveManager.save_game()
	UIManager.close_current_ui()

func _on_load_pressed():
	UIManager.close_current_ui()
	await get_tree().process_frame
	SaveManager.load_game()

func _on_exit_pressed():
	get_tree().quit()
