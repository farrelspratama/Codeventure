extends CanvasLayer

signal video_finished

var is_active: bool = false
var should_unpause: bool = false

@onready var control: Control = $Control
@onready var video_stream_player: VideoStreamPlayer = $Control/Panel/VideoStreamPlayer
@onready var play_button: Button = $Control/Panel/PlayButton
@onready var pause_button: Button = $Control/Panel/PauseButton
@onready var close_button: Button = $Control/CloseButton
@onready var black_screen: ColorRect = $Control/Panel/BlackScreen

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	control.process_mode = Node.PROCESS_MODE_ALWAYS
	
	control.visible = false
	
	play_button.pressed.connect(_on_play_pressed)
	pause_button.pressed.connect(_on_pause_pressed)
	close_button.pressed.connect(_on_close_pressed)
	video_stream_player.finished.connect(_on_video_finished_playing)

func show_video(stream: VideoStream, auto_pause: bool = true) -> void:
	is_active = true
	control.visible = true
	
	should_unpause = auto_pause
	if auto_pause:
		get_tree().paused = true 
	
	if AudioManager:
		AudioManager.mute_music()
	
	video_stream_player.stream = stream
	
	black_screen.modulate.a = 1.0
	black_screen.show()
	play_button.show()
	close_button.show()

func hide_video() -> void:
	is_active = false
	control.visible = false
	video_stream_player.stop()
	
	if AudioManager:
		AudioManager.unmute_music()
	
	if should_unpause:
		get_tree().paused = false

func _on_play_pressed() -> void:
	if video_stream_player.paused:
		video_stream_player.paused = false
	elif not video_stream_player.is_playing():
		var tween = create_tween()
		tween.tween_property(black_screen, "modulate:a", 0.0, 0.5)
		video_stream_player.play()

func _on_pause_pressed() -> void:
	if video_stream_player.is_playing() and not video_stream_player.paused:
		video_stream_player.paused = true

func _on_video_finished_playing() -> void:
	var tween = create_tween()
	tween.tween_property(black_screen, "modulate:a", 1.0, 0.5)
	close_button.show() # Gembok terbuka!

func _on_close_pressed() -> void:
	hide_video()
	video_finished.emit()
