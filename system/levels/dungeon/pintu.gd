extends Node2D

@export_file("*.tscn") var target_level : String 
@export var correct_passcode: String = "1234" # Ganti kodenya lewat Inspector per pintu

@onready var area_2d: Area2D = $Area2D

var player_in_range : bool = false
var is_ui_open : bool = false # Mencegah UI terbuka berulang kali

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	area_2d.area_entered.connect(_on_area_entered)
	area_2d.area_exited.connect(_on_area_exited)
	
	PlayerManager.interact_pressed.connect(_on_interact_pressed)

func _on_area_entered(area: Area2D) -> void:
	if area.get_parent().get_parent() is Player:
		player_in_range = true

func _on_area_exited(area: Area2D) -> void:
	if area.get_parent().get_parent() is Player:
		player_in_range = false

func _on_interact_pressed() -> void:
	# Jika player di dekat pintu dan UI belum terbuka
	if player_in_range and not is_ui_open:
		open_passcode_ui()

func open_passcode_ui() -> void:
	is_ui_open = true
	
	# Sambungkan sinyal dari Autoload ke Pintu ini
	_connect_signals()
	
	# Panggil UI dan kirimkan kode yang benar untuk dicocokkan
	PasscodeMenu.show_menu(correct_passcode)

func _connect_signals() -> void:
	if not PasscodeMenu.passcode_submitted.is_connected(_on_passcode_submitted):
		PasscodeMenu.passcode_submitted.connect(_on_passcode_submitted)
	if not PasscodeMenu.passcode_cancelled.is_connected(_on_ui_closed):
		PasscodeMenu.passcode_cancelled.connect(_on_ui_closed)

func _disconnect_signals() -> void:
	if PasscodeMenu.passcode_submitted.is_connected(_on_passcode_submitted):
		PasscodeMenu.passcode_submitted.disconnect(_on_passcode_submitted)
	if PasscodeMenu.passcode_cancelled.is_connected(_on_ui_closed):
		PasscodeMenu.passcode_cancelled.disconnect(_on_ui_closed)

func _on_passcode_submitted(is_correct: bool) -> void:
	if is_correct:
		print("Pintu: Kode Benar! Membuka Portal...")
		
		# Bersihkan sinyal dan buka pintu
		_disconnect_signals()
		is_ui_open = false
		
		change_level()
	else:
		# Jika salah, UI tetap terbuka (tidak panggil _on_ui_closed).
		# Pemain bebas mencoba lagi sampai benar atau menekan batal.
		print("Pintu: Kode Salah!")

func _on_ui_closed() -> void:
	# Jika pemain menekan tombol tutup/cancel
	is_ui_open = false
	_disconnect_signals()
	print("Pintu: Input Passcode Dibatalkan.")

func change_level() -> void:
	if target_level != "":
		# Hentikan Player agar tidak masuk area lain saat transisi
		player_in_range = false 
		LevelManager.load_new_level(target_level, "", Vector2.ZERO)
	else:
		push_warning("GAGAL: Kolom 'Target Level' di Inspector belum diisi!")
