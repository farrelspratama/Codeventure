extends Area2D

@export_file("*.tscn") var target_level : String 

var player_in_range : bool = false

func _ready() -> void:
	# DEBUG 1: Cek apakah script terpasang dan target level sudah diisi
	print("--- DEBUG KOMPUTER ---")
	print("1. Script Komputer aktif! Target level: ", target_level)
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	PlayerManager.interact_pressed.connect(_on_interact_pressed)

func _on_body_entered(body: Node2D) -> void:
	# DEBUG 2: Cek apakah Area2D mendeteksi sentuhan
	print("2. [Komputer] Ada benda menyentuh area: ", body.name)
	
	if body == PlayerManager.player:
		player_in_range = true
		print("3. [Komputer] Yang menyentuh adalah Player! Siap menerima interaksi.")
	else:
		print("   -> Benda yang menyentuh BUKAN PlayerManager.player!")

func _on_body_exited(body: Node2D) -> void:
	if body == PlayerManager.player:
		player_in_range = false
		print("X. [Komputer] Player menjauh dari komputer.")

func _on_interact_pressed() -> void:
	# DEBUG 3: Cek apakah sinyal tombol dari PlayerManager sampai ke sini
	print("4. [Komputer] Mendengar sinyal tombol interaksi ditekan!")
	
	if player_in_range:
		player_in_range = false 
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
