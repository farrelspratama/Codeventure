class_name InventoryMenuClass extends CanvasLayer

@onready var exit_button: Button = $ExitButton
@onready var item_description_label: Label = $ItemDescriptionLabel
@onready var grid_container: GridContainer = $PanelContainer/GridContainer
@onready var use_button: Button = $UseButton

@export var data : InventoryData

var slot_button_group := ButtonGroup.new()
const INVENTORY_SLOT = preload("res://system/ui/inventory/inventory_slot.tscn")

# --- Variabel untuk melacak item yang sedang dipilih ---
var selected_item_data: ItemData = null 

func _ready() -> void:
	hide_menu()
	exit_button.pressed.connect(_on_exit_button_pressed)
	
	# Hubungkan tombol Use
	use_button.pressed.connect(_on_use_button_pressed)
	use_button.disabled = true # Matikan tombol secara default

func show_menu():
	visible = true
	update_inventory()

func hide_menu():
	visible = false
	selected_item_data = null # Reset pilihan saat ditutup
	use_button.disabled = true

func clear_inventory():
	for c in grid_container.get_children():
		c.queue_free()

func update_inventory():
	clear_inventory()
	item_description_label.text = "Pilih item untuk melihat deskripsi."
	use_button.disabled = true 
	selected_item_data = null
	
	# Loop sebanyak jumlah maksimal slot yang ada di InventoryData (data.slots)
	for s in data.slots:
		var new_slot = INVENTORY_SLOT.instantiate()
		grid_container.add_child(new_slot)
		
		# Gabungkan ke dalam satu ButtonGroup agar hanya bisa memilih 1 slot
		new_slot.button.button_group = slot_button_group
		
		# Set datanya. Jika 's' null, script inventory_slot.gd akan otomatis memanggil 
		# clear_slot() dan membuat ikonnya kosong.
		new_slot.slot_data = s 
		
		# Kita hubungkan sinyal 'pressed' langsung ke tombolnya,
		# agar kita tahu kapan slot ditekan (meskipun slot itu kosong)
		new_slot.button.pressed.connect(_on_any_slot_pressed.bind(new_slot))

func _on_any_slot_pressed(slot_node):
	# Cek apakah slot yang diklik memiliki item
	if slot_node.slot_data != null and slot_node.slot_data.item_data != null:
		selected_item_data = slot_node.slot_data.item_data
		item_description_label.text = selected_item_data.description
		
		# Nyalakan tombol Use jika item ini adalah buku materi
		if selected_item_data.materi_scene != null or selected_item_data.video_stream != null:
			use_button.disabled = false 
		else:
			use_button.disabled = true
			
	else:
		# Jika slot kosong yang diklik, reset tampilan
		selected_item_data = null
		item_description_label.text = "Slot kosong."
		use_button.disabled = true

# --- FUNGSI BARU SAAT TOMBOL USE DITEKAN ---
func _on_use_button_pressed():
	if selected_item_data != null:
		# 1. Simpan data ke variabel lokal terlebih dahulu
		var judul_materi = selected_item_data.name
		var scene_materi = selected_item_data.materi_scene
		var stream_video = selected_item_data.video_stream # Ambil juga data videonya
		
		# 2. Tutup menu inventory 
		UIManager.close_current_ui()
		
		# 3. PERCABANGAN: Panggil UI yang sesuai dengan isi item
		if stream_video != null:
			print("Memutar Video Materi: ", judul_materi)
			# Panggil Autoload VideoPlayer (pastikan nama Autoload-nya sesuai)
			VideoPlayer.show_video(stream_video, true)
			
		elif scene_materi != null:
			print("Membuka Buku Materi: ", judul_materi)
			# Panggil Autoload Materi
			MateriUI.show_materi(judul_materi, scene_materi)

func _on_exit_button_pressed():
	UIManager.close_current_ui()
