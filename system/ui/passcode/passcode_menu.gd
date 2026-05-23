extends CanvasLayer

signal passcode_submitted(is_correct: bool)
signal passcode_cancelled

var expected_passcode: String = ""

@onready var control: Control = $Control
@onready var line_edit: LineEdit = $Control/PanelContainer/VBoxContainer/LineEdit
@onready var submit_button: Button = $Control/PanelContainer/SubmitButton
@onready var close_button: Button = $Control/CloseButton

func _ready() -> void:
	# PROCESS_MODE_ALWAYS wajib agar UI ini kebal terhadap efek pause
	process_mode = Node.PROCESS_MODE_ALWAYS
	control.visible = false
	
	submit_button.pressed.connect(_on_submit_pressed)
	close_button.pressed.connect(_on_cancel_pressed)
	
	# Opsional: Memungkinkan submit menggunakan tombol "Enter" di keyboard
	line_edit.text_submitted.connect(func(_text): _on_submit_pressed())

func show_menu(correct_code: String) -> void:
	if Hud:
		Hud.visible = false
	
	expected_passcode = correct_code
	control.visible = true
	line_edit.text = ""
	
	# Pause seluruh game agar Player tidak bisa bergerak atau interaksi ganda
	get_tree().paused = true 
	
	# Fokuskan kursor ke LineEdit
	line_edit.grab_focus()

func hide_menu() -> void:
	if Hud:
		Hud.visible = true
	
	control.visible = false
	
	# Kembalikan jalannya game
	get_tree().paused = false 

func _on_submit_pressed() -> void:
	# Cek apakah kode cocok
	if line_edit.text == expected_passcode:
		hide_menu()
		passcode_submitted.emit(true)
	else:
		# Jika salah, kosongkan kolom agar pemain bisa mengetik ulang
		line_edit.text = ""
		print("UI: Kode Salah!")
		passcode_submitted.emit(false)

func _on_cancel_pressed() -> void:
	hide_menu()
	passcode_cancelled.emit()
