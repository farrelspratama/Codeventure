extends Node

const SAVE_PATH = "user://"

signal game_loaded
signal game_saved

var is_loading : bool = false

var current_save : Dictionary = {
	scene_path = "",
	player = {
		nama = "",
		kelas = "",
		score = 0,
		pos_x = 392,
		pos_y = -270
	},
	items = [],
	persistence = [],
	quests = []
}

# Tambahkan parameter opsional 'override_scene_path'
func save_game(override_scene_path : String = "") -> void:
	update_player_data()
	
	# Jika kita memberikan jalur paksa (saat pindah level), gunakan jalur tersebut.
	# Jika tidak, deteksi otomatis menggunakan update_scene_path()
	if override_scene_path != "":
		current_save.scene_path = override_scene_path
	else:
		update_scene_path()
		
	update_item_data()
	update_quest_data()
	
	var file := FileAccess.open(SAVE_PATH + "save.sav", FileAccess.WRITE)
	if file == null:
		push_error("Gagal membuka file save!")
		return
	
	var save_json = JSON.stringify(current_save)
	file.store_line(save_json)
	
	game_saved.emit()
	print("Save Game berhasil disimpan!")

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH + "save.sav"):
		push_warning("Save file tidak ditemukan!")
		return
	
	var file := FileAccess.open(SAVE_PATH + "save.sav", FileAccess.READ)
	if file == null:
		push_error("Gagal membuka file save!")
		return
	
	var json := JSON.new()
	var parse_result = json.parse(file.get_line())
	
	if parse_result != OK:
		push_error("JSON parse error!")
		return
	
	var save_dict : Dictionary = json.get_data()
	current_save = save_dict
	
	is_loading = true
	
	# 1. LOAD DATA INVENTORY & QUEST
	PlayerManager.INVENTORY_DATA.parse_save_data(current_save.items)
	QuestManager.current_quests = current_save.quests
	
	# 2. LOAD SCENE LEVELNYA
	if current_save.scene_path != "":
		# --- PERBAIKAN: Berikan kata kunci "LOAD_GAME" sebagai target_transition ---
		LevelManager.load_new_level(current_save.scene_path, "LOAD_GAME", Vector2.ZERO)
		await LevelManager.level_loaded
	
	LevelManager.target_transition = ""
	
	is_loading = false
	
	game_loaded.emit()
	print("Game Loaded - Player diposisikan pada koordinat save terakhir.")

func update_player_data() -> void:
	# Cek dulu apakah player sudah benar-benar ada
	if PlayerManager.player != null and is_instance_valid(PlayerManager.player):
		var p : Player = PlayerManager.player
		current_save.player.pos_x = p.global_position.x
		current_save.player.pos_y = p.global_position.y

func update_scene_path() -> void:
	# Cara Godot yang paling bersih untuk mengambil path scene utama yang sedang aktif
	var current = get_tree().current_scene
	if current != null and current.scene_file_path != "":
		current_save.scene_path = current.scene_file_path

func update_item_data() -> void:
	current_save.items = PlayerManager.INVENTORY_DATA.get_save_data()

func update_quest_data() -> void:
	current_save.quests = QuestManager.current_quests

func add_persistent_value( value : String ) -> void:
	if check_persistent_value( value ) == false:
		current_save.persistence.append( value )
	pass

func check_persistent_value( value : String ) -> bool:
	var p = current_save.persistence as Array
	return p.has( value )
