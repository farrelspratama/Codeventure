extends CanvasLayer

signal minigame_finished
signal minigame_cancelled

var is_active: bool = false
var should_unpause: bool = false

@onready var control: Control = $Control
@onready var question_container: VBoxContainer = $Control/PanelContainer/VBoxContainer/VBoxContainer
@onready var submit: Button = $Control/PanelContainer/VBoxContainer/Button
@onready var close_button: Button = $Control/CloseButton

var current_question: QuestionData
var spawned_inputs: Array[LineEdit] = [] # Menyimpan referensi kotak teks
var spawned_slots: Array[Dictionary] = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	control.visible = false
	submit.pressed.connect(_on_submit_pressed)
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
	spawned_slots.clear()
	
	for child in question_container.get_children():
		child.queue_free()
		
	var lines = q_data.question_text.split("\n") 
	for line in lines:
		var line_container = HBoxContainer.new()
		question_container.add_child(line_container)
		
		var parts = line.split("[SLOT]") 
		for i in range(parts.size()):
			if parts[i] != "":
				var lbl = Label.new()
				lbl.text = parts[i]
				lbl.add_theme_color_override("font_color", Color.BLACK)
				lbl.add_theme_font_size_override("font_size", 48)
				line_container.add_child(lbl)
			
			if i < parts.size() - 1:
				# 1. BUAT KOLOM INPUT
				var input_field = LineEdit.new()
				input_field.add_theme_font_size_override("font_size", 48)
				input_field.custom_minimum_size = Vector2(100, 30)
				input_field.placeholder_text = "ketik..."
				line_container.add_child(input_field)
				
				# 2. BUAT IKON VALIDASI (Tepat di sebelah input)
				var result_icon = Label.new()
				result_icon.hide() # Sembunyikan saat awal
				line_container.add_child(result_icon)
				
				# 3. SIMPAN KEDUANYA BERPASANGAN KE DALAM ARRAY
				spawned_slots.append({
					"input": input_field,
					"icon": result_icon
				})

func _on_submit_pressed():
	if current_question.correct_answers.size() != spawned_slots.size():
		print("ERROR: Kunci jawaban tidak sesuai dengan jumlah [SLOT]!")
		return

	submit.disabled = true 
	
	var all_correct = true
	var wrong_slots = [] 
	
	for i in range(spawned_slots.size()):
		var slot_data = spawned_slots[i]
		var input_field = slot_data["input"]
		var result_icon = slot_data["icon"]
		
		var player_answer = input_field.text.strip_edges().to_lower()
		var correct_answer = current_question.correct_answers[i].strip_edges().to_lower()
		
		if player_answer == "":
			print("Masih ada kotak yang kosong!")
			submit.disabled = false
			return 
			
		# Tampilkan ikon
		result_icon.show()
		
		if player_answer == correct_answer:
			result_icon.text = "✅"
			input_field.editable = false # Kunci ketikan agar tidak bisa diubah lagi jika sudah benar
		else:
			result_icon.text = "❌"
			all_correct = false
			wrong_slots.append(slot_data)
			
	if all_correct:
		print("Jawaban benar semua! Menunggu 1 detik...")
		await get_tree().create_timer(1.0, true).timeout 
		
		submit.disabled = false
		minigame_finished.emit()
		hide_minigame() 
	else:
		print("Ada jawaban yang salah! Menunggu 1.5 detik...")
		await get_tree().create_timer(1.5, true).timeout 
		
		# Reset HANYA kolom yang salah
		for slot_data in wrong_slots:
			slot_data["input"].text = ""
			slot_data["icon"].hide()
			
		submit.disabled = false

func _on_close_pressed() -> void:
	minigame_cancelled.emit() # Beritahu peti bahwa kuis dibatalkan
	hide_minigame()
