@tool
class_name MinigameInteraction extends Area2D

signal player_interacted
signal finished

@export var enabled: bool = true
@export var question_data: QuestionData # Masukkan file soal .tres di sini

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func player_interact() -> void:
	if question_data == null:
		print("Error: Soal belum diisi di Inspector!")
		return
		
	player_interacted.emit()
	
	# Sambungkan sinyal selesai dari Autoload Minigame
	DragNDrop.minigame_finished.connect(_on_minigame_finished)
	
	# Panggil UI Minigame
	DragNDrop.show_minigame(question_data)

func _on_area_entered(_a: Area2D) -> void:
	if enabled == false:
		return
	PlayerManager.interact_pressed.connect(player_interact)

func _on_area_exited(_a: Area2D) -> void:
	PlayerManager.interact_pressed.disconnect(player_interact)

func _on_minigame_finished() -> void:
	DragNDrop.minigame_finished.disconnect(_on_minigame_finished)
	
	# Pancarkan sinyal finished. Ini yang akan ditangkap oleh QuestAdvanceTrigger!
	finished.emit()
