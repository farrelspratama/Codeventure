extends CanvasLayer

@onready var control: Control = $Control
@onready var title_label: Label = $Control/PanelContainer/VBoxContainer/HBoxContainer/TitleLabel
@onready var content_container: VBoxContainer = $Control/PanelContainer/VBoxContainer/ContentContainer
@onready var page_label: Label = $Control/PanelContainer/VBoxContainer/HBoxContainer2/PageLabel
@onready var prev_button: Button = $Control/PanelContainer/VBoxContainer/HBoxContainer2/PrevButton
@onready var next_button: Button = $Control/PanelContainer/VBoxContainer/HBoxContainer2/NextButton
@onready var close_button: Button = $Control/CloseButton

var tab_container: TabContainer # Tidak pakai @onready karena akan diisi secara dinamis
var current_page: int = 0
var total_pages: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS 
	control.visible = false
	
	prev_button.pressed.connect(_on_prev_pressed)
	next_button.pressed.connect(_on_next_pressed)
	close_button.pressed.connect(hide_materi)

# Fungsi ini sekarang menerima Judul dan File Scene Materi
func show_materi(judul: String, materi_scene: PackedScene) -> void:
	if Hud:
		Hud.visible = false
	
	# 1. Update Judul
	title_label.text = judul
	
	# 2. Bersihkan materi sebelumnya (jika ada)
	for child in content_container.get_children():
		child.queue_free()
		
	# 3. Cetak materi baru dan masukkan ke dalam bingkai
	tab_container = materi_scene.instantiate()
	content_container.add_child(tab_container)
	
	# 4. Sembunyikan tab-nya secara paksa lewat script agar aman
	tab_container.tabs_visible = false
	
	# 5. Hitung jumlah halaman
	total_pages = tab_container.get_child_count()
	current_page = 0
	
	control.visible = true
	get_tree().paused = true 
	update_ui()

func hide_materi() -> void:
	if Hud:
		Hud.visible = true
	control.visible = false
	get_tree().paused = false 

func _on_prev_pressed() -> void:
	if current_page > 0:
		current_page -= 1
		update_ui()

func _on_next_pressed() -> void:
	if current_page < total_pages - 1:
		current_page += 1
		update_ui()

func update_ui() -> void:
	if tab_container != null:
		tab_container.current_tab = current_page
		
	page_label.text = str(current_page + 1) + " / " + str(total_pages)
	prev_button.disabled = (current_page == 0)
	next_button.disabled = (current_page == total_pages - 1)
