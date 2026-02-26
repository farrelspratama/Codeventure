extends CharacterBody2D

var direction : Vector2 = Vector2.ZERO
var last_direction: Vector2 = Vector2.DOWN
const move_speed : float = 50.0
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var move_state_machine = $AnimationTree.get("parameters/MoveStateMachine/playback")

func _physics_process(_delta) -> void:
	move()
	animate()

func move():
	# Get the input direction and handle the movement.
	direction = Input.get_vector("left", "right", "up", "down")
	
	#Update velocity
	velocity = direction * move_speed
	
	move_and_slide()

func animate():
	if direction != Vector2.ZERO:
		var dir_anim = Vector2(round(direction.x), round(direction.y))
		move_state_machine.travel('Walk')
		animation_tree.set("parameters/MoveStateMachine/Idle/blend_position", dir_anim)
		animation_tree.set("parameters/MoveStateMachine/Walk/blend_position", dir_anim)
	else:
		move_state_machine.travel('Idle')
