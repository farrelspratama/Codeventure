class_name InventoryMenuClass extends CanvasLayer

@onready var exit_button: Button = $ExitButton
@onready var item_description_label: Label = $ItemDescriptionLabel
@onready var grid_container: GridContainer = $PanelContainer/GridContainer

@export var data : InventoryData

var is_paused: bool = false
var slot_button_group := ButtonGroup.new()
const INVENTORY_SLOT = preload("res://system/ui/inventory/inventory_slot.tscn")

func _ready() -> void:
	hide_inventory_menu()
	exit_button.pressed.connect(_on_exit_button_pressed)


func clear_inventory() -> void:
	for c in grid_container.get_children():
		c.queue_free()


func update_inventory() -> void:
	clear_inventory()
	item_description_label.text = "Pilih item untuk melihat deskripsi."
	
	for s in data.slots:
		var new_slot = INVENTORY_SLOT.instantiate()
		grid_container.add_child(new_slot)
		
		new_slot.slot_data = s
		
		new_slot.button.button_group = slot_button_group
		
		new_slot.slot_clicked.connect(_on_slot_clicked)
	
	if grid_container.get_child_count() > 0:
		grid_container.get_child(0).grab_focus()


func _on_slot_clicked(slot_data) -> void:
	item_description_label.text = slot_data.item_data.description


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		toggle_inventory()
		get_viewport().set_input_as_handled()


func toggle_inventory() -> void:
	is_paused = !is_paused
	get_tree().paused = is_paused
	visible = is_paused
	
	if is_paused:
		update_inventory()


func hide_inventory_menu() -> void:
	is_paused = false
	get_tree().paused = false
	visible = false


func _on_exit_button_pressed() -> void:
	hide_inventory_menu()
