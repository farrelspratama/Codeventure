class_name Level extends Node2D

@export var music : AudioStream

@onready var game: Level = $"."

func _ready() -> void:
	game.y_sort_enabled = true
	PlayerManager.set_as_parent(game)
	
	if PlayerManager.player:
		PlayerManager.player.visible = true
		PlayerManager.player.set_physics_process(true)
		PlayerManager.player.process_mode = Node.PROCESS_MODE_INHERIT
		var camera = PlayerManager.player.get_node_or_null("Camera2D")
		
		# --- PERBAIKAN: Cukup cek string kosong saja ---
		# Jika target_transition berisi "LOAD_GAME", blok ini otomatis dilewati!
		if LevelManager.target_transition == "":
			var spawn_point = find_child("PlayerSpawn", true, false)
			if spawn_point and spawn_point is Node2D:
				PlayerManager.set_player_position(spawn_point.global_position)
				camera.force_snap()
				
		# KONDISI B: Pemain masuk dari Load Game
		elif LevelManager.target_transition == "LOAD_GAME":
			# Tarik koordinat save dan pindahkan pemain SEKARANG, selagi layar masih hitam!
			var saved_pos = Vector2(SaveManager.current_save.player.pos_x, SaveManager.current_save.player.pos_y)
			PlayerManager.set_player_position(saved_pos)
			camera.force_snap()
			print("Player di-spawn langsung ke titik Save: ", saved_pos)
	
	AudioManager.play_music(music)

	if Hud:
		Hud.visible = true
	
	if not LevelManager.level_load_started.is_connected(_free_level):
		LevelManager.level_load_started.connect(_free_level)
	
	UIManager.register_ui(
		get_node("/root/PauseMenu"),
		get_node("/root/InventoryMenu"),
		get_node("/root/CharacterMenu"),
		get_node("/root/Dialog")
	)

func _free_level() -> void:
	UIManager.close_current_ui()
	PlayerManager.unparent_player( self )
	queue_free()
