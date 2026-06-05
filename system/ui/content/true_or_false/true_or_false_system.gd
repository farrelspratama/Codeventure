extends CanvasLayer

signal minigame_finished
signal minigame_cancelled

var is_active: bool = false
var should_unpause: bool = false
var current_question: QuestionData

@onready var control: Control = $Control
# Sesuaikan path ini dengan nama node Anda di Scene Tree!
@onready var question_label: Label = $Control/PanelContainer/VBoxContainer/VBoxContainer/QuestionLabel
@onready var button_true: Button = $Control/PanelContainer/VBoxContainer/VBoxContainer/HBoxContainer/ButtonTrue
@onready var button_false: Button = $Control/PanelContainer/VBoxContainer/VBoxContainer/HBoxContainer/ButtonFalse
@onready var result_icon: Label = $Control/PanelContainer/VBoxContainer/VBoxContainer/HBoxContainer/ResultIcon
@onready var close_button: Button = $Control/CloseButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	control.visible = false
	
	# Hubungkan tombol langsung dengan mengirimkan argumen string
	button_true.pressed.connect(_on_answer_selected.bind("true"))
	button_false.pressed.connect(_on_answer_selected.bind("false"))
	
	close_button.pressed.connect(_on_close_pressed)

func show_minigame(q_data: QuestionData, auto_pause: bool = true) -> void:
	is_active = true
	control.visible = true
	
	should_unpause = auto_pause
	if auto_pause:
		get_tree().paused = true 
		
	load_question(q_data)

func hide_minigame() -> void:
	is_active = false
	control.visible = false
	
	if should_unpause:
		get_tree().paused = false

func load_question(q_data: QuestionData) -> void:
	self.current_question = q_data
	# Tampilkan soal utuh, pastikan font-nya terbaca (misal ubah warna ke hitam jika background putih)
	question_label.text = q_data.question_text
	question_label.add_theme_color_override("font_color", Color.BLACK)
	
	result_icon.hide()
	button_true.disabled = false
	button_false.disabled = false

func _on_answer_selected(player_answer: String):
	if current_question.correct_answers.size() == 0:
		print("ERROR: Kunci jawaban belum diisi di file Resource!")
		return
		
	# Matikan tombol sementara agar pemain tidak spam klik saat sedang divalidasi
	button_true.disabled = true
	button_false.disabled = true
	
	var correct_answer = current_question.correct_answers[0].strip_edges().to_lower()
	
	# Tampilkan ikon
	result_icon.show()
	
	if player_answer == correct_answer:
		result_icon.text = "✅"
		print("Jawaban benar! Menunggu 1 detik...")
		# Beri jeda 1 detik sebelum menutup minigame
		await get_tree().create_timer(1.0, true).timeout
		hide_minigame()
		minigame_finished.emit()
	else:
		result_icon.text = "❌"
		print("Jawaban salah! Menunggu 1.5 detik...")
		# Beri jeda 1.5 detik agar pemain melihat tanda silang
		await get_tree().create_timer(1.5, true).timeout 
		
		# Reset agar pemain bisa mencoba lagi
		result_icon.hide()
		button_true.disabled = false
		button_false.disabled = false

func _on_close_pressed() -> void:
	hide_minigame()
	minigame_cancelled.emit()
