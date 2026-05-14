extends Button

func _get_drag_data(at_position):
	# Membuat visual transparan saat ditarik
	var preview = self.duplicate()
	preview.modulate.a = 0.5
	set_drag_preview(preview)

	# Kita mengirimkan referensi dari tombol ini (self) dan teksnya
	return {
		"text": self.text,
		"source": self
	}

func _can_drop_data(at_position, data):
	return false # Tombol tidak menerima drop
