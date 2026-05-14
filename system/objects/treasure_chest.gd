@tool
class_name TreasureChest extends Node2D

@export var item_data : ItemData : set = _set_item_data
@export var question_data: QuestionData

var is_open: bool = false
var player_in_range: bool = false
var minigame_in_progress: bool = false

@onready var area_2d: Area2D = $Area2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var is_open_data: PersistentDataHandler = $IsOpen

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	area_2d.area_entered.connect(_on_area_entered)
	area_2d.area_exited.connect(_on_area_exited)
	
	is_open_data.data_loaded.connect(set_chest_state)
	set_chest_state()


func _process(_delta) -> void:
	if player_in_range and Input.is_action_just_pressed("interact") and not minigame_in_progress:
		player_interact()


func player_interact() -> void:
	if is_open:
		return
	
	if question_data != null:
		minigame_in_progress = true
		
		# Tentukan script autoload mana yang akan digunakan
		var target_minigame = null
		
		if question_data.game_type == QuestionData.GameType.DRAG_AND_DROP:
			target_minigame = DragNDrop
		elif question_data.game_type == QuestionData.GameType.TEXT_INPUT:
			target_minigame = TextInput
		elif question_data.game_type == QuestionData.GameType.TRUE_FALSE:
			target_minigame = TrueOrFalse
		
		# Jalankan fungsi koneksi aman
		if target_minigame != null:
			_connect_minigame(target_minigame)
			target_minigame.show_minigame(question_data, true)
	else:
		open_chest()

func _connect_minigame(minigame_node: Node) -> void:
	# Cek finished signal
	if not minigame_node.minigame_finished.is_connected(_on_minigame_finished):
		minigame_node.minigame_finished.connect(_on_minigame_finished)
		
	# Cek cancelled signal
	if not minigame_node.minigame_cancelled.is_connected(_on_minigame_cancelled):
		minigame_node.minigame_cancelled.connect(_on_minigame_cancelled)

# Fungsi ini hanya akan terpanggil jika minigame berhasil diselesaikan (jawaban benar semua)
func _on_minigame_finished() -> void:
	minigame_in_progress = false
	_disconnect_all_signals()
	open_chest()

# --- FUNGSI BARU UNTUK MENANGANI PENUTUPAN / PEMBATALAN ---
func _on_minigame_cancelled() -> void:
	minigame_in_progress = false
	_disconnect_all_signals()
	print("Minigame dibatalkan. Peti siap diklik kembali.")
# ----------------------------------------------------------

# Fungsi bantuan untuk membersihkan semua koneksi sinyal agar rapi dan tidak bocor
func _disconnect_all_signals() -> void:
	var list = [DragNDrop, TextInput, TrueOrFalse]
	for m in list:
		if m.minigame_finished.is_connected(_on_minigame_finished):
			m.minigame_finished.disconnect(_on_minigame_finished)
		if m.minigame_cancelled.is_connected(_on_minigame_cancelled):
			m.minigame_cancelled.disconnect(_on_minigame_cancelled)

# Logika membuka peti dan memberikan item
func open_chest() -> void:
	is_open = true
	is_open_data.set_value()
	print("Chest opened")
	animation_player.play("open_chest")
	
	if item_data != null:
		PopupItem.show_item(item_data)

func _set_item_data(value : ItemData) -> void:
	item_data = value

func _on_area_entered(area: Area2D) -> void:
	if area.get_parent().get_parent() is Player:
		player_in_range = true
		print("Player near chest")

func _on_area_exited(area: Area2D) -> void:
	if area.get_parent().get_parent() is Player:
		player_in_range = false
		print("Player left chest")

func set_chest_state() -> void:
	is_open = is_open_data.value
	if is_open:
		animation_player.play("open_chest")
	else:
		animation_player.play("RESET")
