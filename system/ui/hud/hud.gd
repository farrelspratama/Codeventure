extends CanvasLayer

@onready var menu_button: Button = $Control/MenuButton
@onready var inventory_button: Button = $Control/InventoryButton

func _ready():
	menu_button.pressed.connect(_on_menu_pressed)
	inventory_button.pressed.connect(_on_inventory_button_pressed)

func _on_menu_pressed():
	get_node("/root/PauseMenu").toggle_pause()

func _on_inventory_button_pressed():
	get_node("/root/InventoryMenu").toggle_inventory()
