extends Node

signal finished

@export var nama_quest: String = "Misi Ruang Arsip" # Sesuaikan dengan judul Quest Anda
@export var step_final: String = "semua_lemari_selesai"
@export var completed: bool = false
@export var grup_lemari: String = "lemari_quest"

var total_lemari_selesai: int = 0
var target_lemari: int = 0

func _ready() -> void:
	# Beri jeda 1 frame agar seluruh node lemari di scene selesai dimuat
	await get_tree().process_frame
	
	# Ambil semua node yang masuk ke dalam grup
	var daftar_lemari = get_tree().get_nodes_in_group(grup_lemari)
	
	# Target otomatis menyesuaikan dengan jumlah lemari yang ditemukan!
	target_lemari = daftar_lemari.size()
	
	if target_lemari == 0:
		print("PERINGATAN: Tidak ada lemari yang ditemukan di dalam grup '", grup_lemari, "'!")
		return
		
	print("Misi dimulai! Total target lemari di scene ini: ", target_lemari)
	
	# Hubungkan sinyal secara otomatis lewat perulangan (loop)
	for lemari in daftar_lemari:
		# Pastikan node tersebut benar-benar punya sinyal yang dimaksud agar tidak eror
		if lemari.has_signal("all_minigames_completed"):
			lemari.all_minigames_completed.connect(_on_lemari_selesai)
		else:
			print("ERROR: Node ", lemari.name, " tidak memiliki sinyal 'all_minigames_completed'!")

func _on_lemari_selesai() -> void:
	total_lemari_selesai += 1
	print("Lemari diselesaikan: ", total_lemari_selesai, "/5")
	
	# Cek apakah progress sudah mencapai target dinamis
	if total_lemari_selesai >= target_lemari:
		print("Semua lemari di scene ini selesai! Mengirim sinyal ke Quest Manager...")
		QuestManager.update_quest(nama_quest, step_final, completed)
		finished.emit()
