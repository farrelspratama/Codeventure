class_name World extends Node2D

@onready var dialog_interaction: DialogInteraction = $DialogInteraction
@onready var mobil: Node2D = $Mobil4

func _ready() -> void:
	PlayerManager.set_as_parent(self)
	await get_tree().process_frame
	
	if PlayerManager.player:
		PlayerManager.player.visible = false
		PlayerManager.player.set_physics_process(false)
	
	if Hud:
		Hud.visible = false	
	
	# Hubungkan sinyal selesainya dialog system ke fungsi ganti hari/scene.
	# CONNECT_ONE_SHOT sangat penting agar fungsi ini tidak terpicu lagi oleh percakapan lain!
	Dialog.finished.connect(_on_intro_cutscene_finished, CONNECT_ONE_SHOT)
	
	# EKSEKUSI SEMUA ANTREAN SECARA OTOMATIS
	# Memanggil player_interact() akan mengumpulkan semua anak DialogItem
	# dan mengirimkannya ke DialogSystem secara berurutan.
	if dialog_interaction.has_method("player_interact"):
		dialog_interaction.player_interact()

func _on_mobil_sampai() -> void:
	await SceneTransition.fade_out()
	if PlayerManager.player:
		# Munculkan player (efek turun mobil)
		PlayerManager.player.visible = true
		
		# Pindahkan kamera ke player
		var camera = mobil.get_node_or_null("Camera2D")
		if camera:
			camera.reparent(PlayerManager.player)
			camera.position = Vector2.ZERO 
		
		await SceneTransition.fade_in()

func _on_intro_cutscene_finished() -> void:
	print("Intro Selesai! Memulai efek ganti hari...")
	
	# Tentukan level selanjutnya
	var next_level_path = "res://system/levels/world/monolog_02.tscn"
	
	# Pindah scene
	LevelManager.load_new_level(next_level_path, "", Vector2.ZERO)
