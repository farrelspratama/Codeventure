extends Node

signal quest_updated(q)

const QUEST_DATA_LOCATION : String = "res://system/quest_system/quests/"

var quests : Array[ Quest ]
var current_quests : Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gather_quest_data()

func _unhandled_input( event: InputEvent ) -> void:
	if event.is_action_pressed("test"):
		print("Quest: ", current_quests)

func gather_quest_data() -> void:
	# Gather all quest resources and add to quests array
	var quest_files : PackedStringArray = DirAccess.get_files_at( QUEST_DATA_LOCATION )
	quests.clear()
	
	for q in quest_files:
		# Abaikan file cache .uid yang kadang muncul di Godot 4
		if q.ends_with(".uid"):
			continue
			
		# BERSIHKAN NAMA FILE: Hapus akhiran .remap jika game dimainkan di versi .exe
		var clean_name = q.replace(".remap", "")
		
		# Pastikan yang diload hanya file .tres
		if clean_name.ends_with(".tres"):
			var quest_resource = load( QUEST_DATA_LOCATION + "/" + clean_name ) as Quest
			
			if quest_resource != null:
				quests.append( quest_resource )
				
	print("Quest Count: ", quests.size())

func update_quest( _title : String, _completed_step : String = "", _is_complete : bool = false ) -> void:
	var quest_index : int = get_quest_index_by_title( _title )
	if quest_index == -1:
		# Quest was not found - add it to the current quests array
		var new_quest : Dictionary = {
				title = _title,
				is_complete = _is_complete,
				completed_steps = []
		}
		
		if _completed_step != "":
			new_quest.completed_steps.append( _completed_step.to_lower() )
		
		current_quests.append( new_quest )
		quest_updated.emit( new_quest )
		
		# Display a notification that quests was added
		Hud.queue_notification("Misi Dimulai!", _title)
		SaveManager.save_game()
		pass
	else:
		# Quest was found, update it
		var q = current_quests[ quest_index ]
		if _completed_step != "" and q.completed_steps.has( _completed_step ) == false:
			q.completed_steps.append( _completed_step.to_lower() )
			pass
		
		q.is_complete = _is_complete
		
		quest_updated.emit( q )
		
		if q.is_complete == true:
			Hud.queue_notification("Misi Selesai!", _title)
			disperse_quest_rewards( find_quest_by_title( _title ) )
			SaveManager.save_game()
		else:
			Hud.queue_notification("Misi Diperbarui!", _title + ": " + _completed_step.capitalize())
			SaveManager.save_game()

func disperse_quest_rewards( _q : Quest ) -> void:
	var _message : String = "Score: " + str(_q.reward_score)
	
	PlayerManager.reward_score( _q.reward_score )
	
	for i in _q.reward_items:
		PlayerManager.INVENTORY_DATA.add_item( i.item )
		_message += ", " + i.item.name
	
	Hud.queue_notification("Hadiah Diterima!", _message)

func find_quest( _quest : Quest ) -> Dictionary:
	for q in current_quests:
		if q.title.to_lower() == _quest.title.to_lower():
			return q
	return { title = "not found", is_complete = false, completed_steps = [''] }

func find_quest_by_title( _title : String ) -> Quest:
	for q in quests:
		if q.title.to_lower() == _title.to_lower():
			return q
	return null

func get_quest_index_by_title( _title : String ) -> int:
	for i in current_quests.size():
		if current_quests[ i ].title.to_lower() == _title.to_lower():
			return i
	return -1

func sort_quests() -> void:
	var active_quests : Array = []
	var completed_quests : Array = []
	for q in current_quests:
		if q.is_complete:
			completed_quests.append( q )
		else:
			active_quests.append( q )
	
	active_quests.sort_custom( sort_quests_ascending )
	completed_quests.sort_custom( sort_quests_ascending )
	
	current_quests = active_quests
	current_quests.append_array( completed_quests )

func sort_quests_ascending( a, b ):
	if a.title < b.title:
		return true
	return false
