@tool
@icon("res://assets/icons/cutscene_actor.svg") # Gunakan ikon yang ada
class_name CutsceneActionPlayerMove extends CutsceneAction

enum Method { DURATION, SPEED }

@export var timing_method : Method = Method.DURATION
@export var transition_type : Tween.TransitionType = Tween.TransitionType.TRANS_LINEAR
@export var easing_method : Tween.EaseType = Tween.EaseType.EASE_IN_OUT
@export_range( 0.0, 10.0, 0.05, "s" ) var move_duration : float = 0.5
@export_range( 10, 1000, 1, "px/s" ) var move_speed : float = 100.0

var target_location : Vector2 = Vector2.ZERO

func _ready() -> void:
	target_location = global_position
	pass

func play() -> void:
	if Engine.is_editor_hint():
		finished.emit()
		return
		
	# Ambil data pemain langsung dari Autoload
	var player = PlayerManager.player
	
	if player != null:
		# 1. Matikan kontrol fisika (keyboard) agar tidak bentrok dengan Tween
		player.set_physics_process(false)
		player.process_mode = Node.PROCESS_MODE_ALWAYS
		
		var start_location = player.global_position
		var distance_to_target = start_location.distance_to(target_location)
		var move_direction = start_location.direction_to(target_location)
		
		if timing_method == Method.SPEED:
			move_duration = distance_to_target / move_speed
		
		# 2. Atur arah dan putar animasi Walk secara manual ke AnimationTree
		player.direction = move_direction
		player.set_direction()
		player.handle_animation()
		
		# 3. Gerakkan pemain menggunakan Tween
		var tween : Tween = create_tween()
		tween.set_ease(easing_method)
		tween.set_trans(transition_type)
		tween.tween_property(player, "global_position", target_location, move_duration)
		tween.tween_callback(_on_tween_finished)
	else:
		finished.emit()
	pass

# Gunakan argumen bind untuk membawa referensi player ke fungsi ini
func _on_tween_finished() -> void:
	var player = PlayerManager.player
	# 4. Kembalikan animasi ke posisi diam (Idle)
	player.direction = Vector2.ZERO
	player.handle_animation()
	
	# 5. Nyalakan kembali kontrol fisika pemain
	player.set_physics_process(true)
	player.process_mode = Node.PROCESS_MODE_INHERIT
	
	finished.emit()
	pass

func _draw() -> void:
	if Engine.is_editor_hint():
		# Warna hijau agar beda dengan CutsceneActionMove biasa (merah)
		draw_circle(Vector2.ZERO, 3, Color.GREEN)
		draw_circle(Vector2.ZERO, 10, Color(0, 1.0, 0, 0.5), false, 1.0)
	pass
