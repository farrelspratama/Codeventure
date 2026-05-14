@tool
@icon("res://assets/icons/npc.svg")
class_name NPC extends CharacterBody2D

signal do_behavior_enabled

var state : String = "idle"
var direction : Vector2 = Vector2.DOWN
var direction_name : String = "down"
var do_behavior : bool = true
var last_direction : Vector2 = Vector2.ZERO
var last_state : String = ""

@export var npc_resource : NPCResource : set = _set_npc_resource

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_npc()
	if Engine.is_editor_hint():
		return
	gather_interactables()
	do_behavior_enabled.emit()

func _physics_process(_delta: float) -> void:
	move_and_slide()

func gather_interactables() -> void:
	for c in get_children():
		if c is DialogInteraction:
			c.player_interacted.connect( _on_player_interacted )
			c.finished.connect( _on_interaction_finished )

func _on_player_interacted() -> void:
	look_at_target(PlayerManager.player.global_position)
	state = "idle"
	velocity = Vector2.ZERO
	update_animation()
	do_behavior = false
	pass

func _on_interaction_finished() -> void:
	state = "idle"
	update_animation()
	do_behavior = true
	do_behavior_enabled.emit()

func update_animation() -> void:
	var anim_name = state + "_" + direction_name
	
	if anim_name == last_state:
		return
	
	last_state = anim_name
	
	if animation_player.has_animation(anim_name):
		animation_player.play(anim_name)
		animation_player.advance(0)
	else:
		print("Animasi tidak ditemukan:", anim_name)

func update_direction(target_position: Vector2) -> void:
	var prev_direction = direction
	
	var diff = target_position - global_position
	
	if abs(diff.x) > abs(diff.y):
		direction = Vector2(sign(diff.x), 0)
	else:
		direction = Vector2(0, sign(diff.y))
	
	update_direction_name()
	
	if direction != prev_direction:
		update_animation()

func update_direction_name() -> void:
	if direction == Vector2.UP:
		direction_name = "up"
	elif direction == Vector2.DOWN:
		direction_name = "down"
	elif direction == Vector2.RIGHT:
		direction_name = "right"
	elif direction == Vector2.LEFT:
		direction_name = "left"

func look_at_target(target_position: Vector2) -> void:
	var diff = target_position - global_position
	
	if abs(diff.x) > abs(diff.y):
		direction = Vector2.RIGHT if diff.x > 0 else Vector2.LEFT
	else:
		direction = Vector2.DOWN if diff.y > 0 else Vector2.UP
	
	update_direction_name()

func setup_npc() -> void:
	if npc_resource:
		if sprite_2d:
			sprite_2d.texture = npc_resource.sprite

func _set_npc_resource( _npc : NPCResource ) -> void:
	npc_resource = _npc
	setup_npc()
	pass
