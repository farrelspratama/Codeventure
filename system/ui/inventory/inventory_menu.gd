class_name InventoryMenuClass extends CanvasLayer

@onready var exit_button: Button = $ExitButton
@onready var item_description_label: Label = $ItemDescriptionLabel
@onready var grid_container: GridContainer = $PanelContainer/GridContainer

@export var data : InventoryData

var slot_button_group := ButtonGroup.new()
const INVENTORY_SLOT = preload("res://system/ui/inventory/inventory_slot.tscn")

func _ready() -> void:
	hide_menu()
	exit_button.pressed.connect(_on_exit_button_pressed)

func show_menu():
	visible = true
	update_inventory()

func hide_menu():
	visible = false

func clear_inventory():
	for c in grid_container.get_children():
		c.queue_free()

func update_inventory():
	clear_inventory()
	item_description_label.text = "Pilih item untuk melihat deskripsi."
	
	for s in data.slots:
		var new_slot = INVENTORY_SLOT.instantiate()
		grid_container.add_child(new_slot)
		
		new_slot.slot_data = s
		new_slot.button.button_group = slot_button_group
		new_slot.slot_clicked.connect(_on_slot_clicked)

func _on_slot_clicked(slot_data):
	if slot_data and slot_data.item_data:
		item_description_label.text = slot_data.item_data.description

func _on_exit_button_pressed():
	UIManager.close_current_ui()
