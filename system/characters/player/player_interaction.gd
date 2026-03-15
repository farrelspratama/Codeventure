class_name PlayerInteraction extends Node2D

@onready var player: Player = $".."

func _ready() -> void:
	player.direction_changed.connect( update_direction )

func update_direction( new_direction : Vector2 ) -> void:
	match new_direction:
		Vector2.DOWN:
			position = Vector2(0, 12)
		Vector2.UP:
			position = Vector2(0, -6)
		Vector2.LEFT:
			position = Vector2(-10, 5)
		Vector2.RIGHT:
			position = Vector2(10, 5)
		_:
			position = Vector2(0, 12)
