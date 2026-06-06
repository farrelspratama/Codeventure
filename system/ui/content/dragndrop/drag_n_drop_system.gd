extends CanvasLayer

signal minigame_finished
signal minigame_cancelled

var is_active: bool = false
var should_unpause: bool = false

# Masukkan resource dan scene di Inspector autoload ini
@export var draggable_button_scene: PackedScene 
@export var drop_slot_scene: PackedScene

@onready var control: Control = $Control
@onready var panel_container: PanelContainer = $Control/PanelContainer
@onready var question_container: VBoxContainer = $Control/PanelContainer/VBoxContainer/QuestionContainer
@onready var options_container: HBoxContainer = $Control/PanelContainer/VBoxContainer/OptionsContainer
@onready var submit: Button = $Control/PanelContainer/VBoxContainer/Submit
@onready var close_button: Button = $Control/CloseButton

var current_question: QuestionData
var spawned_slots: Array = []

func _ready() -> void:
	# Agar tetap berjalan saat game di-pause
	process_mode = Node.PROCESS_MODE_ALWAYS
	control.visible = false
	panel_container.visible = false
	submit.pressed.connect(_on_submit_pressed)
	close_button.pressed.connect(_on_close_pressed)

# Fungsi ini akan dipanggil oleh node interaksi (seperti Dialog)
func show_minigame(q_data: QuestionData, auto_pause: bool = true) -> void:
	is_active = true
	control.visible = true
	panel_container.visible = true
	should_unpause = auto_pause
	if auto_pause == true:
		get_tree().paused = true # Pause game jika diminta
	load_question(q_data)

func hide_minigame() -> void:
	is_active = false
	control.visible = false
	panel_container.visible = false
	if should_unpause == true:
		get_tree().paused = false # Un-pause game jika sebelumnya mem-pause

func load_question(q_data: QuestionData) -> void:
	self.current_question = q_data
	spawned_slots.clear()
	
	for child in question_container.get_children():
		child.queue_free()
	for child in options_container.get_children():
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
				var slot = drop_slot_scene.instantiate()
				slot.custom_minimum_size = Vector2(150, 30)
				line_container.add_child(slot)
				spawned_slots.append(slot)
				
	for option_text in q_data.options:
		var btn = draggable_button_scene.instantiate()
		btn.text = option_text
		options_container.add_child(btn)

# Hubungkan tombol Submit di UI Anda ke fungsi ini
func _on_submit_pressed():
	if current_question.correct_answers.size() != spawned_slots.size():
		return

	# Cegah pemain menekan submit berkali-kali saat sedang divalidasi
	submit.disabled = true 
	
	var all_correct = true
	var wrong_slots = [] # Menyimpan kotak mana saja yang salah
	
	# Pengecekan per kotak
	for i in range(spawned_slots.size()):
		var slot = spawned_slots[i]
		var player_answer = slot.get_current_answer().strip_edges()
		var correct_answer = current_question.correct_answers[i].strip_edges()
		
		if player_answer == "":
			print("Masih ada kotak yang kosong!")
			submit.disabled = false
			return 
			
		if player_answer == correct_answer:
			slot.show_validation(true) # Tampilkan Ceklis
		else:
			slot.show_validation(false) # Tampilkan Silang
			all_correct = false
			wrong_slots.append(slot)
			
	if all_correct:
		print("Jawaban benar semua! Menunggu 1 detik...")
		# Beri jeda 1 detik agar pemain puas melihat ceklis hijaunya sebelum ditutup
		await get_tree().create_timer(1.0).timeout 
		submit.disabled = false
		hide_minigame() 
		minigame_finished.emit()
	else:
		print("Ada jawaban yang salah! Menunggu 1.5 detik...")
		# Beri jeda 1.5 detik agar pemain bisa melihat mana yang salah
		await get_tree().create_timer(1.5).timeout 
		
		# Reset HANYA kotak yang salah agar pemain tidak frustrasi
		for slot in wrong_slots:
			slot.clear_slot()
			
		submit.disabled = false

func _on_close_pressed() -> void:
	hide_minigame()
	minigame_cancelled.emit()
