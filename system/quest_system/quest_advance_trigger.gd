@tool
class_name QuestAdvanceTrigger extends QuestNode

signal advanced

@export_category( "Parent Signal Connection" )
@export var signal_name : String = ""

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if signal_name != "":
		if get_parent().has_signal( signal_name ):
			get_parent().connect( signal_name, advance_quest )

func advance_quest() -> void:
	print("ADVANCE QUEST TRIGGERED:", linked_quest.title, get_step())
	if linked_quest == null:
		return
	await get_tree().process_frame
	advanced.emit()
	var _title : String = linked_quest.title
	var _step : String = get_step()
	
	if _step == "N/A":
		_step = ""
	
	QuestManager.update_quest( _title, _step, quest_complete )
