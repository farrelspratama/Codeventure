extends CanvasLayer

@onready var exit_button: Button = $ExitButton
@onready var inventory_slot: InventorySlot = $InventorySlot
@onready var use_button: Button = $UseButton
@onready var item_name_label: Label = $PanelContainer/VBoxContainer/VBoxContainer2/ItemNameLabel

var current_item : ItemData

func _ready():
	# Wajib agar tombol Exit bisa ditekan saat game pause
	process_mode = Node.PROCESS_MODE_ALWAYS 
	hide()
	exit_button.pressed.connect(close_popup)
	
	use_button.pressed.connect(_on_use_button_pressed)

func show_item(item_data: ItemData):	
	current_item = item_data
	item_name_label.text = item_data.name
	
	# Membungkus ItemData ke dalam SlotData sementara agar InventorySlot bisa membacanya
	var temp_slot = SlotData.new()
	temp_slot.item_data = item_data
	inventory_slot.slot_data = temp_slot # Menggunakan setter yang ada di InventorySlot
	
	if current_item.materi_scene != null:
		use_button.show()
	else:
		use_button.hide()
	
	show()
	get_tree().paused = true

func close_popup():
	# Masukkan item ke inventory SAAT popup ditutup
	if current_item:
		PlayerManager.INVENTORY_DATA.add_item(current_item)
		current_item = null # Kosongkan agar tidak ter-add dua kali jika terjadi bug
	
	hide()
	get_tree().paused = false

func _on_use_button_pressed():
	if current_item and current_item.materi_scene != null:
		# 1. Amankan data materi
		var judul_materi = current_item.name
		var scene_materi = current_item.materi_scene
		
		# 2. Tetap masukkan item ke inventory agar tidak hilang
		PlayerManager.INVENTORY_DATA.add_item(current_item)
		current_item = null
		
		# 3. Tutup popup ini dan lepas pause-nya sesaat
		hide()
		get_tree().paused = false
		
		# 4. Langsung panggil MateriUI! (MateriUI akan otomatis mem-pause gamenya lagi)
		MateriUI.show_materi(judul_materi, scene_materi)
