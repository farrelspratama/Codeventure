class_name Player extends CharacterBody2D

signal direction_changed( new_direction: Vector2 )

var direction: Vector2 = Vector2.ZERO
var cardinal_direction: Vector2 = Vector2.DOWN
var current_state: String = "Idle"
var nama : String = "Farrel Setia Pratama"
var kelas : String = "X PPLG 2"
var score : int = 0

const MOVE_SPEED : float = 70.0
const DIR_4 := [
	Vector2.RIGHT,
	Vector2.DOWN,
	Vector2.LEFT,
	Vector2.UP
]

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var move_state_machine = $AnimationTree.get("parameters/MoveStateMachine/playback")

func _physics_process(_delta) -> void:
	handle_movement()
	handle_animation()

func handle_movement():
	# get_vector sudah otomatis membatasi panjang maksimal vektor menjadi 1
	direction = Input.get_vector("left", "right", "up", "down")
	
	velocity = direction * MOVE_SPEED
	move_and_slide()

	set_direction()

func set_direction() -> void:
	if direction == Vector2.ZERO:
		return
	
	var direction_id: int = int(
		round((direction + cardinal_direction * 0.1).angle() / TAU * DIR_4.size())
	)
	
	var new_dir = DIR_4[direction_id]
	
	if new_dir == cardinal_direction:
		return
	
	cardinal_direction = new_dir
	direction_changed.emit(cardinal_direction)

func handle_animation() -> void:
	var target_state: String
	
	if direction != Vector2.ZERO:
		target_state = "Walk"
	else:
		target_state = "Idle"
	
	if target_state != current_state:
		move_state_machine.travel(target_state)
		current_state = target_state
	
	animation_tree.set("parameters/MoveStateMachine/Idle/blend_position", cardinal_direction)
	animation_tree.set("parameters/MoveStateMachine/Walk/blend_position", cardinal_direction)
