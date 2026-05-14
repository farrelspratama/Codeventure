extends Node

const SAVE_PATH = "user://"

signal game_loaded
signal game_saved

var current_save : Dictionary = {
	scene_path = "",
	player = {
		nama = "",
		kelas = "",
		score = 0,
		pos_x = 0,
		pos_y = 0
	},
	items = [],
	persistence = [],
	quests = []
}

func save_game() -> void:
	update_player_data()
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
	print("Save Game")

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
	
	# 1. LOAD DATA INVENTORY & QUEST DULU
	PlayerManager.INVENTORY_DATA.parse_save_data(current_save.items)
	QuestManager.current_quests = current_save.quests
	
	# 2. LOAD SCENE LEVELNYA
	if current_save.scene_path != "":
		# Gunakan 'await' jika LevelManager Anda memuat scene secara asinkron/membutuhkan waktu
		LevelManager.load_new_level(current_save.scene_path, "", Vector2.ZERO)
	
	# 3. SET POSISI PEMAIN SETELAH LEVEL DIMUAT
	# (Pastikan memanggil ini setelah node Player berhasil dibuat oleh LevelManager)
	PlayerManager.set_player_position(Vector2(current_save.player.pos_x, current_save.player.pos_y))
	
	game_loaded.emit()
	print("Game Loaded")

func update_player_data() -> void:
	var p : Player = PlayerManager.player
	current_save.player.pos_x = p.global_position.x
	current_save.player.pos_y = p.global_position.y

func update_scene_path() -> void:
	var p : String = ""
	for c in get_tree().root.get_children():
		if c is Level:
			p = c.scene_file_path
	current_save.scene_path = p

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
