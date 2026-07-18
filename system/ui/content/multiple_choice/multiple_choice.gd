extends CanvasLayer

signal minigame_finished
signal minigame_cancelled

var is_active: bool = false
var should_unpause: bool = false
var current_question: QuestionData
var spawned_buttons: Array[Button] = []

@onready var control: Control = $Control
@onready var question_label: Label = $Control/PanelContainer/VBoxContainer/QuestionLabel
@onready var options_container: VBoxContainer = $Control/PanelContainer/VBoxContainer
@onready var close_button: Button = $Control/CloseButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	control.visible = false
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
	
	# 1. Tampilkan teks soal
	question_label.text = q_data.question_text
	question_label.add_theme_color_override("font_color", Color.BLACK)
	
	# 2. Bersihkan tombol pilihan dari soal sebelumnya (jika ada)
	for btn in spawned_buttons:
		btn.queue_free()
	spawned_buttons.clear()
	
	# 3. Buat tombol pilihan ganda baru secara dinamis berdasarkan data di Resource
	for option_text in q_data.options:
		var btn = Button.new()
		btn.text = option_text
		
		# Pengaturan Sizing Tombol Pilihan agar estetik
		btn.custom_minimum_size = Vector2(0, 50)
		btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		btn.add_theme_font_size_override("font_size", 32)
		
		# Hubungkan tombol langsung dengan mengirimkan teks jawaban tombol tersebut
		btn.pressed.connect(_on_answer_selected.bind(btn, option_text))
		
		# Masukkan ke dalam container dan simpan ke array
		options_container.add_child(btn)
		spawned_buttons.append(btn)

func _on_answer_selected(selected_btn: Button, player_answer: String) -> void:
	if current_question.correct_answers.size() == 0:
		print("ERROR: Kunci jawaban belum diisi di file Resource!")
		return
		
	# 1. Matikan semua tombol sementara agar pemain tidak spam klik
	_set_all_buttons_disabled(true)
	
	var correct_answer = current_question.correct_answers[0].strip_edges().to_lower()
	var clean_player_answer = player_answer.strip_edges().to_lower()
	
	# 2. Validasi Jawaban & Perubahan Warna
	if clean_player_answer == correct_answer:
		# Ubah warna teks tombol menjadi HIJAU jika benar
		selected_btn.add_theme_color_override("font_disabled_color", Color("#4caf50")) # Hijau Terang
		print("Jawaban benar! Menunggu 1 detik...")
		
		await get_tree().create_timer(1.0, true).timeout
		hide_minigame()
		minigame_finished.emit()
	else:
		# Ubah warna teks tombol menjadi MERAH jika salah
		selected_btn.add_theme_color_override("font_disabled_color", Color("#f14c4c")) # Merah Terang
		print("Jawaban salah! Menunggu 1.5 detik...")
		
		await get_tree().create_timer(1.5, true).timeout 
		
		# Reset warna dan nyalakan kembali tombol agar pemain bisa mencoba lagi
		selected_btn.remove_theme_color_override("font_disabled_color")
		_set_all_buttons_disabled(false)

func _set_all_buttons_disabled(status: bool) -> void:
	for btn in spawned_buttons:
		btn.disabled = status

func _on_close_pressed() -> void:
	hide_minigame()
	minigame_cancelled.emit()
