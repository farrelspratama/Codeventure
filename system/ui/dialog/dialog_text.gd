@tool
@icon("res://assets/icons/text_bubble.svg")
class_name DialogText extends DialogItem

@export_multiline var text : String = "Placeholder Text"

@export var can_fast_forward : bool = true # Jika false, siswa TIDAK BISA mempercepat efek ketikan
@export var read_time_delay : float = 0 # Waktu jeda (detik) setelah teks selesai diketik sebelum tombol Lanjut bisa ditekan
@export var image: Texture2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
