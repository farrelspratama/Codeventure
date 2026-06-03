@tool
class_name CutsceneActionShake extends CutsceneAction

@export_range(0.0, 3.0, 0.1) var trauma_power : float = 0.8 # Kekuatan gempa

func play() -> void:
	# Teriakkan instruksi gempa ke seluruh game lewat PlayerManager
	PlayerManager.shake_camera(trauma_power)
	
	await get_tree().create_timer(3.0).timeout
	# Langsung akhiri aksi ini agar cutscene lanjut ke aksi berikutnya (misal: dialog atau animasi)
	# sementara layarnya masih terus bergetar.
	finished.emit()
