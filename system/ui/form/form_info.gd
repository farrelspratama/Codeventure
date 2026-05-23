extends CanvasLayer

@onready var nama_input: LineEdit = $Control/VBoxContainer/NamaLengkap
@onready var kelas_dropdown: OptionButton = $Control/VBoxContainer/Kelas
@onready var submit_button: Button = $Control/SubmitButton
@onready var back_button: Button = $Control/BackButton

func _ready() -> void:
	# Karena opsi kelas sudah diatur di Inspector, kita tidak perlu menambahkannya lewat kode lagi!
	# Kita hanya perlu menghubungkan tombol submit.
	submit_button.pressed.connect(_on_submit_pressed)
	back_button.pressed.connect(_on_back_pressed)
	
	if Hud:
		Hud.visible = false
	
	get_tree().paused = true 

func _on_submit_pressed() -> void:
	var nama_siswa = nama_input.text.strip_edges()
	
	if nama_siswa.is_empty():
		print("Error: Nama tidak boleh kosong!")
		return
		
	if kelas_dropdown.selected == 0 or kelas_dropdown.selected == -1:
		print("Error: Silakan pilih kelas dari menu dropdown!")
		return
	
	var kelas_siswa = kelas_dropdown.get_item_text(kelas_dropdown.selected)
	
	# --- SINKRONISASI SAVE MANAGER ---
	# Kita masukkan nama dan kelas ke dalam struktur kamus data (Dictionary)
	SaveManager.current_save.player.nama = nama_siswa.capitalize()
	SaveManager.current_save.player.kelas = kelas_siswa
	
	# Simpan ke file fisik (save.sav)
	SaveManager.save_game()
	# ---------------------------------
	
	print("Data Disimpan: Nama = ", SaveManager.current_save.player.nama, " | Kelas = ", SaveManager.current_save.player.kelas)
	
	# --- TAMPILKAN TUTORIAL KONTROL ---
	ControlsMenu.show_controls()
	
	# Kode akan "membeku" di baris ini dan menunggu sampai pemain menekan tombol OK di layar kontrol
	await ControlsMenu.controls_closed
	
	SceneTransition.change_scene("res://system/levels/world/monolog_01.tscn")

func _on_back_pressed() -> void:
	print("Dibatalkan! Mengosongkan form dan kembali ke Menu...")
	
	# 1. Bersihkan isian form
	nama_input.clear()
	kelas_dropdown.selected = 0 # Kembali ke indeks 0 ("Pilih Kelas...")
	
	# 2. Lepaskan pause agar game bisa berjalan normal lagi
	get_tree().paused = false
	
	SceneTransition.change_scene("res://system/title_scene/title_scene.tscn")
