class_name CharacterInfo extends Control

@onready var nama: Label = $PanelContainer/VBoxContainer/HBoxContainer/Nama
@onready var kelas: Label = $PanelContainer/VBoxContainer/HBoxContainer2/Kelas
@onready var score: Label = $PanelContainer/VBoxContainer/HBoxContainer3/Score

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CharacterMenu.shown.connect(update_character_info)

func update_character_info() -> void:
	var _p : Player = PlayerManager.player
	nama.text = str(_p.nama)
	kelas.text = str(_p.kelas)
	score.text = str(_p.score)
