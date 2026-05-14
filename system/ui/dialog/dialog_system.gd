@tool
class_name DialogSystemNode extends CanvasLayer

signal finished

var is_active : bool = false
var text_in_progress : bool = false
var waiting_for_choice : bool = false
var minigame_in_progress : bool = false

var text_speed : float = 0.05
var text_length : int = 0
var plain_text : String

var dialog_items : Array[DialogItem]
var dialog_items_index : int = 0

@onready var dialog_ui: Control = $DialogUI
@onready var content: RichTextLabel = $DialogUI/PanelContainer/RichTextLabel
@onready var name_label: Label = $DialogUI/Label
@onready var timer: Timer = $DialogUI/Timer
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $DialogUI/AudioStreamPlayer2D
@onready var v_box_container: VBoxContainer = $DialogUI/VBoxContainer

func _ready() -> void:
	if Engine.is_editor_hint():
		if get_viewport() is Window:
			get_parent().remove_child(self)
			return
		return
	timer.timeout.connect( _on_timer_timeout )
	hide_dialog()

func _unhandled_input(event: InputEvent) -> void:
	if is_active == false or minigame_in_progress == true: 
		return
	if (event.is_action_pressed("interact")):
		if text_in_progress == true:
			content.visible_characters = text_length
			timer.stop()
			text_in_progress = false
			return
		elif waiting_for_choice == true:
			return
		
		advance_dialog()
	pass

func advance_dialog() -> void:
	dialog_items_index += 1
	if dialog_items_index < dialog_items.size():
		start_dialog()
	else:
		hide_dialog()
	pass

func show_dialog( _items : Array[ DialogItem ] ) -> void:
	is_active = true
	dialog_ui.visible = true
	dialog_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	dialog_items = _items
	dialog_items_index = 0
	get_tree().paused = true
	await get_tree().process_frame
	if dialog_items.size() == 0:
		hide_dialog()
	else:
		start_dialog()
	pass

func hide_dialog() -> void:
	is_active = false
	v_box_container.visible = false
	dialog_ui.visible = false
	dialog_ui.process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().paused = false
	finished.emit()
	pass

func start_dialog() -> void:
	waiting_for_choice = false
	var _d : DialogItem = dialog_items[ dialog_items_index ]
	
	if _d is DialogText:
		set_dialog_text( _d as DialogText )
	elif _d is DialogChoice:
		set_dialog_choice( _d as DialogChoice )
	elif _d is DialogMinigame:
		set_dialog_minigame( _d as DialogMinigame )

func set_dialog_text( _d : DialogItem ) -> void:
	if _d is DialogText:
		content.text = _d.text
	name_label.text = _d.npc_info.npc_name
	content.visible_characters = 0
	text_length = content.get_total_character_count()
	plain_text = content.get_parsed_text()
	text_in_progress = true
	start_timer()
	pass

func set_dialog_choice( _d : DialogChoice ) -> void:
	v_box_container.visible = true
	waiting_for_choice = true
	for c in v_box_container.get_children():
		c.queue_free()
	
	for i in _d.dialog_branches.size():
		var _new_choice : Button = Button.new()
		_new_choice.text = _d.dialog_branches[ i ].text
		_new_choice.pressed.connect( _dialog_choice_selected.bind( _d.dialog_branches[ i ] ) )
		v_box_container.add_child( _new_choice )
	
	if Engine.is_editor_hint():
		return
	await get_tree().process_frame
	await get_tree().process_frame
	v_box_container.get_child( 0 )

func _dialog_choice_selected( _d : DialogBranch ) -> void:
	v_box_container.visible = false
	_d.selected.emit()
	show_dialog( _d.dialog_items )
	pass

func set_dialog_minigame(_d: DialogMinigame) -> void:
	# Sembunyikan UI dialog sementara minigame berjalan
	dialog_ui.visible = false 
	
	var q_data = _d.question_data
	if q_data == null:
		advance_dialog()
		return
		
	# --- KONEKSI SINYAL AMAN ---
	if q_data.game_type == QuestionData.GameType.DRAG_AND_DROP:
		_connect_minigame_signals(DragNDrop)
		DragNDrop.show_minigame(q_data, true)
		
	elif q_data.game_type == QuestionData.GameType.TEXT_INPUT:
		_connect_minigame_signals(TextInput)
		TextInput.show_minigame(q_data, true)
		
	elif q_data.game_type == QuestionData.GameType.TRUE_FALSE:
		_connect_minigame_signals(TrueOrFalse)
		TrueOrFalse.show_minigame(q_data, true)

func _connect_minigame_signals(minigame_node: Node) -> void:
	if not minigame_node.minigame_finished.is_connected(_on_minigame_finished):
		minigame_node.minigame_finished.connect(_on_minigame_finished)
		
	if not minigame_node.minigame_cancelled.is_connected(_on_minigame_cancelled):
		minigame_node.minigame_cancelled.connect(_on_minigame_cancelled)

func _disconnect_all_minigame_signals() -> void:
	var minigames = [DragNDrop, TextInput, TrueOrFalse]
	for m in minigames:
		if m.minigame_finished.is_connected(_on_minigame_finished):
			m.minigame_finished.disconnect(_on_minigame_finished)
		if m.minigame_cancelled.is_connected(_on_minigame_cancelled):
			m.minigame_cancelled.disconnect(_on_minigame_cancelled)

func _on_minigame_finished() -> void:
	_disconnect_all_minigame_signals()
	
	# Munculkan kembali UI percakapan dan lanjut ke baris dialog berikutnya
	dialog_ui.visible = true 
	advance_dialog()

func _on_minigame_cancelled() -> void:
	_disconnect_all_minigame_signals()
	
	print("Minigame di dialog dibatalkan. Menutup percakapan NPC...")
	# Langsung tutup total percakapan agar status is_active dan pause di-reset!
	hide_dialog()

func _on_timer_timeout() -> void:
	content.visible_characters += 1
	if content.visible_characters <= text_length:
		audio_stream_player_2d.pitch_scale = randf_range(0.96, 1.04)
		audio_stream_player_2d.play()
		start_timer()
	else:
		text_in_progress = false

func start_timer() -> void:
	timer.wait_time = text_speed
	# Manipulate wait_time
	var _char = plain_text[ content.visible_characters - 1 ]
	if '.!?:;'.contains( _char ):
		timer.wait_time *= 5
	elif ', '.contains( _char ):
		timer.wait_time *= 3
	timer.start()
