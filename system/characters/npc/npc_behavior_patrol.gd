@tool
@icon("res://assets/icons/npc_behavior.svg")
extends NPCBehavior

@export var walk_speed : float = 30.0

var patrol_location : Array[ PatrolLocation ]
var current_location_index : int = 0
var target : PatrolLocation

var is_waiting : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gather_patrol_locations()
	
	if Engine.is_editor_hint():
		child_entered_tree.connect(gather_patrol_locations)
		child_order_changed.connect(gather_patrol_locations)
		return
	
	super()
	
	if patrol_location.size() == 0:
		process_mode = Node.PROCESS_MODE_DISABLED
		return
	
	target = patrol_location[0]
	npc.state = "walk"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if npc.do_behavior == false:
		return
	
	if is_waiting:
		return
	
	npc.update_direction(target.target_position)
	npc.velocity = walk_speed * npc.direction
	npc.update_animation()
	
	if npc.state != "walk":
		npc.state = "walk"
		npc.update_animation()
	
	if npc.global_position.distance_to(target.target_position) < 4:
		reach_target()

func reach_target() -> void:
	is_waiting = true
	
	npc.state = "idle"
	npc.velocity = Vector2.ZERO
	npc.update_animation()
	
	var wait_time : float = target.wait_time
	
	await get_tree().create_timer(wait_time).timeout
	
	if npc.do_behavior == false:
		is_waiting = false
		return
	
	current_location_index += 1
	if current_location_index >= patrol_location.size():
		current_location_index = 0
	
	target = patrol_location[current_location_index]
	
	npc.state = "walk"
	npc.update_animation()
	
	is_waiting = false

func gather_patrol_locations( _n : Node = null ) -> void:
	patrol_location = []
	for c in get_children():
		if c is PatrolLocation:
			patrol_location.append( c )
	
	if Engine.is_editor_hint():
		if patrol_location.size() > 0:
			for i in patrol_location.size():
				var _p = patrol_location[ i ] as PatrolLocation
				
				if not _p.transform_changed.is_connected( gather_patrol_locations ):
					_p.transform_changed.connect( gather_patrol_locations )
				
				_p.update_label( str(i) )
				
				var _next : PatrolLocation
				if i < patrol_location.size() - 1:
					_next = patrol_location[i + 1]
				else:
					_next = patrol_location[ 0 ]
				_p.update_line( _next.position )
