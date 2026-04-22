extends CanvasLayer

@onready var menu_button: Button = $Control/MenuButton
@onready var inventory_button: Button = $Control/InventoryButton
@onready var information_button: Button = $Control/InformationButton
@onready var notification: NotificationUI = $Control/Notification

func _ready():
	menu_button.pressed.connect(_on_menu_pressed)
	inventory_button.pressed.connect(_on_inventory_button_pressed)
	information_button.pressed.connect(_on_information_button_pressed)

func _on_menu_pressed():
	UIManager.toggle_ui(UIManager.UIType.PAUSE)

func _on_inventory_button_pressed():
	UIManager.toggle_ui(UIManager.UIType.INVENTORY)

func _on_information_button_pressed():
	UIManager.toggle_ui(UIManager.UIType.CHARACTER)

func queue_notification(_title : String, _message : String) -> void:
	notification.add_notification_to_queue(_title, _message)
