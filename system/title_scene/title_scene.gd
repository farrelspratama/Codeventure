extends CanvasLayer

# Default level jika pemain memilih New Game
const START_LEVEL_PATH = "res://system/ui/form/form_info.tscn"

@onready var new_game_button: Button = $Control/VBoxContainer/NewGameButton
@onready var continue_button: Button = $Control/VBoxContainer/ContinueButton
@onready var information_button: Button = $Control/VBoxContainer/InformationButton
@onready var credit_button: Button = $Control/VBoxContainer/CreditButton
@onready var exit_button: Button = $Control/VBoxContainer/ExitButton

func _ready() -> void:
	get_tree().paused = false
	
	if Hud:
		Hud.visible = false
	
	new_game_button.pressed.connect(_on_new_game_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	information_button.pressed.connect(_on_information_pressed)
	credit_button.pressed.connect(_on_credit_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	
	# Cek apakah file save tersedia
	_check_save_data()

func _check_save_data() -> void:
	# Memeriksa keberadaan file save menggunakan path dari SaveManager
	var save_file_path = SaveManager.SAVE_PATH + "save.sav"
	
	if FileAccess.file_exists(save_file_path):
		# MUNCULKAN tombol Continue jika file save ada
		continue_button.visible = true
		continue_button.grab_focus() 
	else:
		# HILANGKAN tombol Continue jika belum pernah main / tidak ada save
		continue_button.visible = false
		new_game_button.grab_focus()

func _on_new_game_pressed() -> void:
	# 1. Reset isi current_save di SaveManager agar data lama tidak terbawa
	SaveManager.current_save = {
		scene_path = START_LEVEL_PATH,
		player = { nama = "", kelas = "", score = 0, pos_x = 0, pos_y = 0 },
		items = [],
		persistence = [],
		quests = []
	}
	
	# 2. Reset Inventory pemain (kosongkan tas)
	if PlayerManager.INVENTORY_DATA:
		# Membuat array kosong sejumlah slot yang ada
		var empty_saves = []
		empty_saves.resize(PlayerManager.INVENTORY_DATA.slots.size())
		empty_saves.fill({ "item": "" })
		PlayerManager.INVENTORY_DATA.parse_save_data(empty_saves)
	
	# 3. Pindah ke level awal (Form Info)
	get_tree().change_scene_to_file(START_LEVEL_PATH)

func _on_continue_pressed() -> void:
	# SaveManager.load_game() di kode Anda sudah otomatis memanggil:
	# LevelManager.load_new_level(...) yang akan memindahkan scene.
	# Jadi kita cukup panggil satu baris ini saja!
	if Hud:
		Hud.visible = true
	
	SaveManager.load_game()

func _on_information_pressed() -> void:
	SceneTransition.change_scene("res://system/ui/information/information.tscn")

func _on_credit_pressed() -> void:
	SceneTransition.change_scene("res://system/ui/credits/credits.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
