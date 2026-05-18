extends CanvasLayer

@onready var animation_player: AnimationPlayer = $Control/AnimationPlayer

func _ready() -> void:
	# PASTIKAN layar transisi kebal terhadap efek pause!
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Sembunyikan layar hitam di awal agar tidak menutupi game
	$Control.mouse_filter = Control.MOUSE_FILTER_IGNORE

func fade_out() -> void:
	$Control.mouse_filter = Control.MOUSE_FILTER_STOP # Blokir klik pemain selama transisi
	animation_player.play("fade_out")
	await animation_player.animation_finished

func fade_in() -> void:
	animation_player.play("fade_in")
	await animation_player.animation_finished
	$Control.mouse_filter = Control.MOUSE_FILTER_IGNORE # Izinkan klik lagi

# --- TAMBAHKAN FUNGSI INI ---
func change_scene(target_scene_path: String) -> void:
	# 1. Gelapkan layar
	await fade_out()
	
	# 2. Pindah scene (Di titik ini layar pemain sepenuhnya hitam)
	get_tree().change_scene_to_file(target_scene_path)
	
	# 3. Terangkan layar kembali untuk menampilkan scene yang baru
	await fade_in()
