@tool
@icon("res://assets/icons/chat_bubbles.svg")
class_name DialogInteraction extends Area2D

signal player_interacted
signal finished

@export var enabled : bool = true

var dialog_items : Array[ DialogItem ]
var is_interacting : bool = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	animation_player.play("show")
	
	area_entered.connect( _on_area_entered )
	area_exited.connect( _on_area_exited )
	
	for c in get_children():
		if c is DialogItem:
			dialog_items.append( c )
	
	pass

func player_interact() -> void:
	# Jika dialog/minigame sedang berjalan, abaikan tekanan tombol dari pemain
	if is_interacting:
		return
		
	print("INTERACT TRIGGERED")
	is_interacting = true # Kunci gemboknya!
	
	player_interacted.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	
	if not Dialog.finished.is_connected(_on_dialog_finished):
		Dialog.finished.connect(_on_dialog_finished)
		
	# Menyerahkan seluruh array dialog dan minigame ke Autoload Dialog
	Dialog.show_dialog( dialog_items )

func _on_area_entered(_a: Area2D) -> void:
	if enabled == false || dialog_items.size() == 0:
		return
	if not PlayerManager.interact_pressed.is_connected(player_interact):
		PlayerManager.interact_pressed.connect( player_interact )
	print("masuk")

func _on_area_exited(_a: Area2D) -> void:
	if PlayerManager.interact_pressed.is_connected(player_interact):
		PlayerManager.interact_pressed.disconnect( player_interact )

func _on_dialog_finished() -> void:
	if Dialog.finished.is_connected(_on_dialog_finished):
		Dialog.finished.disconnect(_on_dialog_finished)
	is_interacting = false # Buka kembali gembok interaksi!
	finished.emit()
	print("Dialog/Minigame Runtutan Selesai Total")

func _get_configuration_warnings() -> PackedStringArray:
	if _check_for_dialog_items() == false:
		return [ "Requires at least one DialogItem node." ]
	else:
		return []

func _check_for_dialog_items() -> bool:
	for c in get_children():
		if c is DialogItem:
			return true
	return false
