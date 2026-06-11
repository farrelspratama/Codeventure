extends CanvasLayer

@onready var close_button: Button = $Control/CloseButton

func _ready() -> void:
	get_tree().paused = false 
	
	close_button.pressed.connect(_on_back_pressed)

func _on_back_pressed() -> void:
	SceneTransition.change_scene("res://system/title_scene/title_scene.tscn")
