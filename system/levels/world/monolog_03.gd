extends Node2D

@onready var dialog_interaction: DialogInteraction = $DialogInteraction

func _ready() -> void:
	# Pastikan game tidak dalam keadaan pause
	get_tree().paused = false
	
	# Sembunyikan HUD jika masih menyala
	if Hud:
		Hud.visible = false
	
	# Sambungkan sinyal jika dialog selesai, arahkan ke Form Info
	Dialog.finished.connect(_on_monolog_finished)
	
	# Beri jeda dramatis 1 detik sebelum teks pertama muncul
	await get_tree().create_timer(1.0).timeout
	
	# Mulai monolog
	if dialog_interaction.has_method("player_interact"):
		dialog_interaction.player_interact()

func _on_monolog_finished() -> void:
	print("Monolog Selesai. Pindah ke Intro...")
	
	var gameplay_level = "res://system/levels/dungeon/array_01.tscn"
	
	LevelManager.load_new_level(gameplay_level, "", Vector2.ZERO)
