extends CanvasLayer

signal video_finished

@onready var video_stream_player: VideoStreamPlayer = $Control/Panel/VideoStreamPlayer
@onready var play_button: Button = $Control/Panel/PlayButton
@onready var close_button: Button = $Control/CloseButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	video_stream_player.process_mode = Node.PROCESS_MODE_ALWAYS
	
	visible = false
	
	play_button.pressed.connect(_on_play_pressed)
	close_button.pressed.connect(_on_close_pressed)
	video_stream_player.finished.connect(_on_video_finished_playing)

func show_video(stream: VideoStream) -> void:
	video_stream_player.stream = stream 
	visible = true
	
	# Fitur Wajib Tonton
	play_button.show()
	close_button.hide()
	
	video_stream_player.play()
	video_stream_player.paused = true

func _on_play_pressed() -> void:
	play_button.hide()
	video_stream_player.play()

func _on_video_finished_playing() -> void:
	play_button.show() 
	close_button.show() # Gembok terbuka!
	
	video_stream_player.paused = true

func _on_close_pressed() -> void:
	video_stream_player.stop()
	visible = false
	
	# Pancarkan sinyal bahwa video telah ditutup
	video_finished.emit()
