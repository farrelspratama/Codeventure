class_name Level extends Node

@onready var game: Node2D = $"."

func _ready() -> void:
	game.y_sort_enabled = true
	PlayerManager.set_as_parent(game)
	
	# --- PERBAIKAN 1: SPAWN PLAYER DI TITIK YANG DITENTUKAN ---
	if PlayerManager.player:
		# Hidupkan kembali player yang sempat dimatikan/disembunyikan saat intro
		PlayerManager.player.visible = true
		PlayerManager.player.set_physics_process(true)
		PlayerManager.player.process_mode = Node.PROCESS_MODE_INHERIT
		
		# Cari node bernama "PlayerSpawn" secara otomatis di dalam level ini
		var spawn_point = find_child("PlayerSpawn", true, false)
		
		if spawn_point and spawn_point is Node2D:
			# Pindahkan posisi player ke koordinat Marker2D tersebut
			PlayerManager.set_player_position(spawn_point.global_position)
			print("Player berhasil di-spawn pada posisi: ", spawn_point.global_position)
		else:
			print("Peringatan: Node 'PlayerSpawn' (Marker2D) tidak ditemukan di level ini!")

	# --- PERBAIKAN 2: MUNCULKAN KEMBALI HUD GAMEPLAY ---
	if Hud:
		Hud.visible = true
	
	# --- LOGIKA BAWAN LEVEL ANDA ---
	if not LevelManager.level_load_started.is_connected(_free_level):
		LevelManager.level_load_started.connect(_free_level)
	
	UIManager.register_ui(
		get_node("/root/PauseMenu"),
		get_node("/root/InventoryMenu"),
		get_node("/root/CharacterMenu"),
		get_node("/root/Dialog")
	)
	
	await SceneTransition.fade_in()

func _free_level() -> void:
	UIManager.close_current_ui()
	PlayerManager.unparent_player(game)
	queue_free()
