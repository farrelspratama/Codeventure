extends CanvasLayer

@export var scroll_speed: float = 60.0 # Kecepatan teks bergulir

@onready var credits_text: RichTextLabel = $CreditsText
@onready var close_button: Button = $CloseButton

var is_scrolling: bool = false

func _ready() -> void:
	# Pastikan game tidak dalam kondisi pause
	get_tree().paused = false 
	
	close_button.pressed.connect(_on_back_pressed)
	
	# Sembunyikan scrollbar bawaan
	credits_text.scroll_active = false
	
	# --- PERBAIKAN PENTING: Buka Gembok Ukuran Kotak ---
	credits_text.fit_content = true # Paksa kotak memanjang ke bawah sesuai isi teks!
	credits_text.clip_contents = false # Jangan potong teks yang keluar dari batas kotak
	
	# Tunggu 1 frame agar Godot selesai menghitung panjang teks Anda yang baru
	await get_tree().process_frame 
	# ----------------------------------------------------
	
	# Sekarang, letakkan teks tepat di bawah layar
	credits_text.position.y = get_viewport().get_visible_rect().size.y
	
	# Beri jeda 1 detik sebelum teks mulai naik (efek sinematik)
	await get_tree().create_timer(1.0).timeout
	is_scrolling = true

func _process(delta: float) -> void:
	if is_scrolling:
		# Dorong teks ke atas (Y minus) dikali delta agar halus
		credits_text.position.y -= scroll_speed * delta
		
		# Cek jika teks sudah sepenuhnya melewati batas atas layar
		# (-credits_text.size.y artinya posisi kotak teks sudah murni di atas layar)
		if credits_text.position.y < -credits_text.size.y:
			_finish_credits()

func _on_back_pressed() -> void:
	# Jika pemain menekan tombol lewati
	_finish_credits()

func _finish_credits() -> void:
	# Hentikan guliran dan kembali ke Main Menu
	is_scrolling = false
	SceneTransition.change_scene("res://system/title_scene/title_scene.tscn")
