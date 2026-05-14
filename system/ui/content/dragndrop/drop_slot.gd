extends Panel

var current_button_source: Button = null

# Referensi ke Label di dalam Panel ini untuk menampilkan teks jawaban
@onready var answer_label: Label = $Label
@onready var result_icon: Label = $ResultIcon

func _ready():
	answer_label.text = "" # Kosongkan saat awal
	result_icon.hide()

func _can_drop_data(at_position, data):
	# Pastikan data valid
	return typeof(data) == TYPE_DICTIONARY and data.has("text") and data.has("source")

func _drop_data(at_position, data):
	# Jika SEBELUMNYA sudah ada jawaban, munculkan kembali tombol aslinya di opsi bawah
	if current_button_source != null:
		current_button_source.show()
	
	# Simpan referensi tombol BARU yang baru saja di-drop
	current_button_source = data["source"]
	
	# Sembunyikan tombol tersebut dari HBoxContainer (seolah-olah pindah ke atas)
	current_button_source.hide()
	
	# Tampilkan teksnya di slot jawaban
	answer_label.text = data["text"]
	
	result_icon.hide()

func show_validation(is_correct: bool):
	result_icon.show()
	if is_correct:
		result_icon.text = "✅" # Anda bisa ganti dengan TextureRect jika punya gambar
	else:
		result_icon.text = "❌"

# Fungsi bantuan untuk mereset slot
func clear_slot():
	if current_button_source != null:
		current_button_source.show()
	current_button_source = null
	answer_label.text = ""

# Fungsi untuk mengambil jawaban saat ini
func get_current_answer() -> String:
	return answer_label.text
