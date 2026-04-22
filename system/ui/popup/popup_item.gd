extends CanvasLayer

@onready var inventory_slot: InventorySlot = $PanelContainer/InventorySlot
@onready var item_name_label: Label = $ItemNameLabel
@onready var exit_button: Button = $ExitButton

var current_item : ItemData

func _ready():
	hide()
	exit_button.pressed.connect(close_popup)

func show_item(item_data: ItemData):	
	current_item = item_data
	inventory_slot.set_item(item_data)
	item_name_label.text = item_data.name
	
	show()
	get_tree().paused = true

func close_popup():
	if current_item:
		PlayerManager.INVENTORY_DATA.add_item(current_item)
	
	hide()
	get_tree().paused = false
