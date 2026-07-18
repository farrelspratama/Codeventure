extends Panel

var current_button_source: Button = null

# Referensi ke Label di dalam Panel ini untuk menampilkan teks jawaban
@onready var answer_label: Label = $Label

var warna_benar = Color("#4caf50")
var warna_salah = Color("#f14c4c")

func _ready():
	answer_label.text = ""

func _can_drop_data(_at_position, data):
	# Pastikan data valid
	return typeof(data) == TYPE_DICTIONARY and data.has("text") and data.has("source")

func _drop_data(_at_position, data):
	# Jika SEBELUMNYA sudah ada jawaban, munculkan kembali tombol aslinya di opsi bawah
	if current_button_source != null:
		current_button_source.show()
	
	# Simpan referensi tombol BARU yang baru saja di-drop
	current_button_source = data["source"]
	
	# Sembunyikan tombol tersebut dari HBoxContainer (seolah-olah pindah ke atas)
	current_button_source.hide()
	
	# Tampilkan teksnya di slot jawaban
	answer_label.text = data["text"]
	
	# Reset warna teks kembali ke normal (default Inspector) saat jawaban baru masuk!
	answer_label.remove_theme_color_override("font_color")

func show_validation(is_correct: bool):
	if is_correct:
		answer_label.add_theme_color_override("font_color", warna_benar)
	else:
		answer_label.add_theme_color_override("font_color", warna_salah)

# Fungsi bantuan untuk mereset slot
func clear_slot():
	if current_button_source != null:
		current_button_source.show()
	current_button_source = null
	answer_label.text = ""
	answer_label.remove_theme_color_override("font_color")

# Fungsi untuk mengambil jawaban saat ini
func get_current_answer() -> String:
	return answer_label.text
