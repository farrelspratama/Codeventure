class_name Player extends CharacterBody2D

var direction : Vector2 = Vector2.ZERO
var last_direction: Vector2 = Vector2.DOWN
var current_state: String = "Idle"
const move_speed : float = 50.0
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var move_state_machine = $AnimationTree.get("parameters/MoveStateMachine/playback")

func _physics_process(_delta) -> void:
	handle_movement()
	handle_animation()

func handle_movement():
	direction = Vector2(Input.get_vector("left", "right", "up", "down")).normalized()
	
	if direction != Vector2.ZERO:
		last_direction = direction
	
	velocity = direction * move_speed
	move_and_slide()

func handle_animation():
	var target_state: String
	
	if direction != Vector2.ZERO:
		target_state = "Walk"
	else:
		target_state = "Idle"
	
	if target_state != current_state:
		move_state_machine.travel(target_state)
		current_state = target_state
	
	var anim_direction := Vector2(
		round(last_direction.x),
		round(last_direction.y)
	)
	
	animation_tree.set("parameters/MoveStateMachine/Idle/blend_position", anim_direction)
	animation_tree.set("parameters/MoveStateMachine/Walk/blend_position", anim_direction)
