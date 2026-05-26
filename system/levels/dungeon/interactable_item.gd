@tool
class_name InteractableItem extends Node2D

signal all_minigames_completed

@export var item_data : ItemData : set = _set_item_data

# UBAH DI SINI 1: Menjadi Array agar bisa menampung banyak soal
@export var questions: Array[QuestionData]

var is_interacted: bool = false
var player_in_range: bool = false
var minigame_in_progress: bool = false

# Variabel baru untuk melacak urutan soal yang sedang dikerjakan
var current_question_index: int = 0

@onready var area_2d: Area2D = $Area2D
@onready var animation_player: AnimationPlayer = $InteractableIcon/AnimationPlayer
@onready var is_interacted_data: PersistentDataHandler = $IsInteractable

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	area_2d.area_entered.connect(_on_area_entered)
	area_2d.area_exited.connect(_on_area_exited)
	
	is_interacted_data.data_loaded.connect(set_item_state)
	set_item_state()


func _process(_delta) -> void:
	if player_in_range and Input.is_action_just_pressed("interact") and not minigame_in_progress:
		player_interact()


func player_interact() -> void:
	if is_interacted:
		return
	
	# UBAH DI SINI 2: Cek apakah array soal memiliki isi dan indeks belum melewati batas
	if questions.size() > 0 and current_question_index < questions.size():
		minigame_in_progress = true
		
		# Ambil data soal sesuai urutan saat ini
		var current_question = questions[current_question_index]
		var target_minigame = null
		
		if current_question.game_type == QuestionData.GameType.DRAG_AND_DROP:
			target_minigame = DragNDrop
		elif current_question.game_type == QuestionData.GameType.TEXT_INPUT:
			target_minigame = TextInput
		elif current_question.game_type == QuestionData.GameType.TRUE_FALSE:
			target_minigame = TrueOrFalse
		
		# Jalankan fungsi koneksi aman
		if target_minigame != null:
			_connect_minigame(target_minigame)
			target_minigame.show_minigame(current_question, true)
	else:
		# Jika array kosong atau semua soal sudah terjawab, buka peti!
		open_chest()


func _connect_minigame(minigame_node: Node) -> void:
	if not minigame_node.minigame_finished.is_connected(_on_minigame_finished):
		minigame_node.minigame_finished.connect(_on_minigame_finished)
		
	if not minigame_node.minigame_cancelled.is_connected(_on_minigame_cancelled):
		minigame_node.minigame_cancelled.connect(_on_minigame_cancelled)


# UBAH DI SINI 3: Logika saat 1 soal berhasil dijawab
func _on_minigame_finished() -> void:
	minigame_in_progress = false
	_disconnect_all_signals()
	
	# Naikkan urutan ke soal berikutnya
	current_question_index += 1
	
	# Cek apakah masih ada soal tersisa
	if current_question_index < questions.size():
		# Gunakan call_deferred untuk memberi jeda 1 frame dengan aman 
		# sebelum UI soal berikutnya dipanggil (mencegah bug tumpang tindih UI)
		call_deferred("player_interact")
	else:
		# Jika semua soal di dalam array sudah habis terjawab
		open_chest()


func _on_minigame_cancelled() -> void:
	minigame_in_progress = false
	_disconnect_all_signals()
	
	# UBAH DI SINI 4: Reset indeks ke 0 agar jika pemain membatalkan minigame, 
	# mereka harus mengulang menjawab rentetan soal dari awal.
	current_question_index = 0
	
	print("Minigame dibatalkan. Peti siap diklik kembali.")


func _disconnect_all_signals() -> void:
	var list = [DragNDrop, TextInput, TrueOrFalse]
	for m in list:
		if m.minigame_finished.is_connected(_on_minigame_finished):
			m.minigame_finished.disconnect(_on_minigame_finished)
		if m.minigame_cancelled.is_connected(_on_minigame_cancelled):
			m.minigame_cancelled.disconnect(_on_minigame_cancelled)


func open_chest() -> void:
	is_interacted = true
	is_interacted_data.set_value()
	print("Chest opened")
	
	all_minigames_completed.emit()
	
	# Matikan hint setelah interaksi tuntas
	animation_player.play("RESET")
	
	if item_data != null:
		PopupItem.show_item(item_data)


func _set_item_data(value : ItemData) -> void:
	item_data = value


func _on_area_entered(area: Area2D) -> void:
	if area.get_parent().get_parent() is Player:
		player_in_range = true
		if is_interacted == false:
			animation_player.play("show")
		print("Player near item")


func _on_area_exited(area: Area2D) -> void:
	if area.get_parent().get_parent() is Player:
		player_in_range = false
		animation_player.play("RESET")
		print("Player left item")


func set_item_state() -> void:
	is_interacted = is_interacted_data.value
	animation_player.play("RESET")
