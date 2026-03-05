class_name InventorySlot extends Control

var slot_data : SlotData : set = set_slot_data

signal slot_clicked(slot_data)

@onready var button: Button = $Button

func _ready() -> void:
	clear_slot()
	button.pressed.connect(_on_button_pressed)

func set_slot_data( value : SlotData ) -> void:
	slot_data = value
	
	if slot_data == null:
		clear_slot()
		return
	
	button.icon = slot_data.item_data.texture

func clear_slot() -> void:
	button.icon = null

func _on_button_pressed() -> void:
	if slot_data:
		slot_clicked.emit(slot_data)
