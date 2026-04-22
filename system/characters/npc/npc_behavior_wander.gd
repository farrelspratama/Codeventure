@tool
extends NPCBehavior

const DIRECTIONS = [ Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT ]

@export var wander_range : int = 2 : set = _set_wander_range
@export var wander_speed : float = 30.0
@export var wander_duration : float = 1.0
@export var idle_duration : float = 1.0

var original_position : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	super()
	$CollisionShape2D.queue_free()
	original_position = npc.global_position

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	#if abs( global_position.distance_to( original_position ) ) > wander_range * 32:
		#npc.velocity *= -1
		#npc.direction *= -1
		#npc.update_direction( global_position + npc.direction )
		#npc.update_animation()

func start() -> void:
	if npc.do_behavior == false:
		return
	
	# IDLE
	npc.state = "idle"
	npc.velocity = Vector2.ZERO
	npc.update_animation()
	await get_tree().create_timer(randf() * idle_duration + idle_duration * 0.5).timeout
	if npc.do_behavior == false:
		return
	
	# WALK
	npc.state = "walk"
	var dir : Vector2
	var attempts := 0

	while attempts < 10:
		var candidate = DIRECTIONS[randi_range(0,3)]
		var next_pos = npc.global_position + candidate * 32  # 1 tile
		
		if next_pos.distance_to(original_position) <= wander_range * 32:
			dir = candidate
			break
		
		attempts += 1

	# fallback (kalau semua arah keluar area)
	if dir == null:
		dir = (original_position - npc.global_position).normalized()
		dir = Vector2(sign(dir.x), sign(dir.y))
	
	npc.direction = dir
	npc.velocity = wander_speed * dir
	
	npc.update_direction_name()
	npc.update_animation()
	
	await get_tree().create_timer(randf() * wander_duration + wander_duration * 0.5).timeout
	
	if npc.do_behavior == false:
		return
	
	start()

func _set_wander_range( v : int ) -> void:
	wander_range = v
	$CollisionShape2D.shape.radius = v * 32.0
