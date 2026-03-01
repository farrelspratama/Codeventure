extends CanvasLayer

@onready var save_button: Button = $VBoxContainer/SaveButton
@onready var load_button: Button = $VBoxContainer/LoadButton
@onready var main_menu_button: Button = $VBoxContainer/MainMenuButton
@onready var exit_button: Button = $VBoxContainer/ExitButton

var is_paused : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide_pause_menu()
	pass # Replace with function body.

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if is_paused == false:
			show_pause_menu()
		else:
			hide_pause_menu()
		get_viewport().set_input_as_handled()

func show_pause_menu() -> void:
	get_tree().paused = true
	visible = true
	is_paused = true

func hide_pause_menu() -> void:
	get_tree().paused = false
	visible = false
	is_paused = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
