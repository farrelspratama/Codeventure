extends Node

const PLAYER = preload("res://system/characters/player/player.tscn")
const INVENTORY_DATA : InventoryData = preload("res://system/inventory/player_inventory.tres")

signal camera_shook( trauma : float )
signal interact_pressed

var interact_handled : bool = true
var player : Player
var player_spawned : bool = false

func _ready() -> void:
	player_spawned = false

func _unhandled_input(event: InputEvent) -> void:
	# Cek apakah game dijalankan dari Editor (Debug). 
	# Jika diekspor (Release), tombol ini tidak akan berfungsi sehingga aman dari siswa!
	if OS.is_debug_build():
		# Tekan tombol Page Up untuk Mode Ngebut (3x Lipat)
		if Input.is_physical_key_pressed(KEY_PAGEUP):
			Engine.time_scale = 3.0
			print("DEBUG: Waktu Dipercepat 3X!")
			
		# Tekan tombol Page Down untuk kembali Normal
		elif Input.is_physical_key_pressed(KEY_PAGEDOWN):
			Engine.time_scale = 1.0
			print("DEBUG: Waktu Normal.")

func add_player_instance() -> void:
	player = PLAYER.instantiate()
	player.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(player)
	player.visible = true
	player_spawned = true

func _ensure_player_exists() -> void:
	# Jika player bernilai null ATAU fisiknya sudah terhapus (freed), buat baru!
	if player == null or not is_instance_valid(player):
		add_player_instance()

func reward_score( _score : int ) -> void:
	player.score += _score
	print("Score: ", str(player.score))

func set_player_position( _new_pos : Vector2 ) -> void:
	_ensure_player_exists()
	player.global_position = _new_pos

func set_as_parent( _p : Node2D ) -> void:
	_ensure_player_exists()
	if player.get_parent():
		player.get_parent().remove_child(player)
	_p.add_child(player)

func unparent_player( _p : Node2D ) -> void:
	_p.remove_child(player)

func _input(event):
	if event.is_action_pressed("interact"):
		print("INTERACT DITEKAN")
		interact()

func interact() -> void:
	interact_handled = false
	interact_pressed.emit()

func shake_camera( trauma : float = 1 ) -> void:
	camera_shook.emit( clampf( trauma, 0.0, 3.0 ) )

func reset_camera_on_player( tween_duration : float = 0.5 ) -> void:
	# --- TAMBAHKAN DUA BARIS PENGAMAN INI ---
	# Jika player belum di-spawn (masih null), batalkan fungsi ini agar tidak error!
	if player == null or not is_instance_valid(player):
		return 
	# ----------------------------------------
	
	var camera : Camera2D = get_viewport().get_camera_2d()
	if camera:
		if camera.get_parent() == player:
			print("Camera already on player")
			return
		camera.reparent( player )
		
		var tween : Tween = create_tween()
		tween.set_ease( Tween.EASE_OUT )
		tween.set_trans( Tween.TRANS_QUAD )
		tween.tween_property( camera, "position", Vector2.ZERO, tween_duration )
	pass
