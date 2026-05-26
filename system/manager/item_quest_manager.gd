extends Node

@export var nama_quest: String = "Misi Ruang Arsip" # Sesuaikan dengan judul Quest Anda
@export var step_final: String = "semua_lemari_selesai"

var total_lemari_selesai: int = 0

func _ready() -> void:
	# Ganti $Lemari1, $Lemari2 dst dengan path node lemari Anda yang sebenarnya di scene
	$"../Items/Lemari".all_minigames_completed.connect(_on_lemari_selesai)
	$"../Items/Lemari2".all_minigames_completed.connect(_on_lemari_selesai)
	$"../Items/Lemari3".all_minigames_completed.connect(_on_lemari_selesai)
	$"../Items/Lemari4".all_minigames_completed.connect(_on_lemari_selesai)
	$"../Items/Lemari5".all_minigames_completed.connect(_on_lemari_selesai)

func _on_lemari_selesai() -> void:
	total_lemari_selesai += 1
	print("Lemari diselesaikan: ", total_lemari_selesai, "/5")
	
	# Jika kelima lemari sudah selesai semua, baru kita naikkan progress quest-nya!
	if total_lemari_selesai >= 5:
		print("Semua lemari selesai! Mengirim sinyal ke Quest Manager...")
		QuestManager.update_quest(nama_quest, step_final, false)
