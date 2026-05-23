extends Node2D

@export_file("*.tscn") var target_level : String 

@onready var area_2d: Area2D = $Area2D

var player_in_range : bool = false

func _ready() -> void:
	# DEBUG 1: Cek apakah script terpasang dan target level sudah diisi
	print("--- DEBUG KOMPUTER ---")
	print("1. Script Komputer aktif! Target level: ", target_level)
	
	area_2d.area_entered.connect(_on_area_entered)
	area_2d.area_exited.connect(_on_area_exited)
	
	PlayerManager.interact_pressed.connect(_on_interact_pressed)

func _on_area_entered(area: Area2D) -> void:
	if area.get_parent().get_parent() is Player:
		player_in_range = true
		print("masuk")

func _on_area_exited(area: Area2D) -> void:
	if area.get_parent().get_parent() is Player:
		player_in_range = false

func _on_interact_pressed() -> void:
	# DEBUG 3: Cek apakah sinyal tombol dari PlayerManager sampai ke sini
	print("4. [Komputer] Mendengar sinyal tombol interaksi ditekan!")
	
	if player_in_range:
		player_in_range = true 
		print("5. [Komputer] Player ada di dekat komputer. Memulai portal...")
		masuk_dunia_komputer()
	else:
		print("   -> Tapi posisi Player sedang JAUH dari komputer.")

func masuk_dunia_komputer() -> void:
	if target_level != "":
		print("6. [Komputer] Pindah ke level: ", target_level)
		LevelManager.load_new_level(target_level, "", Vector2.ZERO)
	else:
		push_warning("GAGAL: Kolom 'Target Level' di Inspector belum diisi!")
