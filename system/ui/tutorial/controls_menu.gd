extends CanvasLayer

signal controls_closed

@onready var control: Control = $Control
@onready var ok_button: Button = $Control/PanelContainer/VBoxContainer/OkButton

func _ready() -> void:
	# Sembunyikan UI saat game pertama kali berjalan
	control.visible = false
	
	# Hubungkan tombol OK
	ok_button.pressed.connect(_on_ok_pressed)

func show_controls() -> void:
	control.visible = true
	get_tree().paused = true
	
	# Arahkan fokus ke tombol agar pemain bisa langsung menekan Enter/Spasi
	ok_button.grab_focus()

func hide_controls() -> void:
	control.visible = false
	get_tree().paused = false
	
	controls_closed.emit()

func _on_ok_pressed() -> void:
	hide_controls()
