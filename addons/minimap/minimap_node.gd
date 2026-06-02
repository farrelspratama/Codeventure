@tool
extends SubViewportContainer
class_name MiniMap

var sub_viewport: SubViewport
var border: Line2D
var placeholder: ColorRect
var camera_2d: Camera2D 
var marker: Sprite2D
var edge_pointer: Sprite2D

@onready var sub_viewport_container: SubViewportContainer = $"."

@export var zoom: float = 0.5:
	set(value):
		zoom = value
		if camera_2d:
			camera_2d.zoom = Vector2(zoom, zoom)

@export var window_size: Vector2i = Vector2i(256,128):
	set(value):
		window_size = value
		if sub_viewport:
			sub_viewport.size = window_size
			update_border()

@export var border_thickness: float = 2.0:
	set(value):
		border_thickness = value
		update_border()

@export var hide_layer2:bool=false

@export var target:Node2D
@export var hide_marker:=false

@export var marker_image:Texture2D:
	set(value):
		marker_image=value
		if marker:
			marker.texture=marker_image
@export var marker_scale:Vector2=Vector2(1,1):
	set(value):
		marker_scale=value
		if marker:
			marker.scale=marker_scale
			
@export var border_line_color:Color=Color.BLACK:
	set(value):
		border_line_color = value
		if border:
			border.default_color = border_line_color

@export var frame_image:PackedScene:
	set(value):
		frame_image = value
		if frame_image:
			# Create an instance of the NinePatchRect scene
			var fameimage = frame_image.instantiate() 
			if fameimage is NinePatchRect and sub_viewport:
				add_child(fameimage)
				fameimage.custom_minimum_size=Vector2(sub_viewport.size.x,sub_viewport.size.y)

@export_group("Edge Pointer")
@export var quest_target: Node2D
@export var pointer_image: Texture2D

@export var pointer_scale: Vector2 = Vector2(1, 1):
	set(value):
		pointer_scale = value
		if edge_pointer:
			edge_pointer.scale = pointer_scale

# Called when the node enters the scene tree for the first time.
func setup():
	if sub_viewport: return  # prevent duplicates

	sub_viewport = SubViewport.new()
	add_child(sub_viewport)

	camera_2d = Camera2D.new()
	sub_viewport.add_child(camera_2d)

	marker = Sprite2D.new()
	add_child(marker)

	border = Line2D.new()
	add_child(border)

	placeholder = ColorRect.new()
	add_child(placeholder)
	
	edge_pointer = Sprite2D.new()
	add_child(edge_pointer) 
	edge_pointer.hide()
	
func _enter_tree():
	if Engine.is_editor_hint():
		setup()
		
func _ready() -> void:
	## iniating everything:
	setup()
	
	add_to_group("minimap_group")
	
	sub_viewport.size=window_size
	marker.texture=marker_image
	if marker_scale and marker_scale != Vector2.ZERO:
		marker.scale=marker_scale
	placeholder.hide()
	camera_2d.zoom=(Vector2(zoom,zoom))
	
	update_border()
	marker.position=Vector2(sub_viewport.size.x/2,sub_viewport.size.y/2)
	
	sub_viewport.world_2d = get_tree().root.world_2d
	
	if not Engine.is_editor_hint():
		LevelManager.tilemap_bounds_changed.connect(_update_limits)
		_update_limits(LevelManager.current_tilemap_bounds)
		
		get_tree().root.set_canvas_cull_mask_bit(1, false)
		
		if hide_layer2 == true:
			sub_viewport.set_canvas_cull_mask_bit(1, false)
		else:
			sub_viewport.set_canvas_cull_mask_bit(1, true)
		
	if frame_image:
		# Create an instance of the NinePatchRect scene
		var fameimage = frame_image.instantiate() 
		if fameimage is NinePatchRect:
			add_child(fameimage)
			fameimage.custom_minimum_size=Vector2(sub_viewport.size.x,sub_viewport.size.y)
	
	if pointer_image:
		edge_pointer.texture = pointer_image
		edge_pointer.scale = pointer_scale

# Called every frame. 'delta' is the elapsed time since the previous frame.
func update_border():
	if not border: return

	border.clear_points()
	border.default_color = border_line_color
	border.width = border_thickness

	var offset = border_thickness / 2.0

	border.add_point(Vector2(offset, offset))
	border.add_point(Vector2(window_size.x - offset, offset))
	border.add_point(Vector2(window_size.x - offset, window_size.y - offset))
	border.add_point(Vector2(offset, window_size.y - offset))
	border.add_point(Vector2(offset, offset))

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
		return
	if target == null and PlayerManager.player != null:
		target = PlayerManager.player
	if target:
		camera_2d.global_position = target.global_position
		
		if quest_target and edge_pointer.texture:
			# Jika mode "Hard Mode" aktif, sembunyikan marker
			if hide_layer2 == true:
				edge_pointer.hide()
			else:
				edge_pointer.show() # Pastikan selalu terlihat!
				
				var diff = quest_target.global_position - target.global_position
				var scaled_diff = diff * zoom 
				
				var extents = Vector2(window_size) / 2.0 
				var is_offscreen = abs(scaled_diff.x) > extents.x or abs(scaled_diff.y) > extents.y
				
				if is_offscreen:
					# KONDISI 1: JAUH (Di luar area minimap)
					# Tempelkan ikon di pinggir border
					var safe_extents = extents - Vector2(15.0, 15.0) 
					var clamp_ratio = max(abs(scaled_diff.x) / safe_extents.x, abs(scaled_diff.y) / safe_extents.y)
					var clamped_pos = scaled_diff / clamp_ratio
					
					edge_pointer.position = extents + clamped_pos
				else:
					# KONDISI 2: DEKAT (Di dalam area minimap)
					# Lepaskan dari pinggir, posisikan persis di titik asli targetnya!
					edge_pointer.position = extents + scaled_diff
					
				# Pastikan ikon (seperti tanda seru) selalu tegak lurus
				edge_pointer.rotation = 0
		else:
			# Jika tidak ada quest_target yang di-assign, sembunyikan pointer
			edge_pointer.hide()

func _update_limits(bounds: Array[Vector2]) -> void:
	if bounds.is_empty() or bounds.size() < 2:
		return
		
	# Langsung suntikkan nilainya ke camera_2d (tidak perlu membuat variabel perantara)
	if camera_2d:
		camera_2d.limit_left = int(bounds[0].x)
		camera_2d.limit_top = int(bounds[0].y)
		camera_2d.limit_right = int(bounds[1].x)
		camera_2d.limit_bottom = int(bounds[1].y)
		
		# Memaksa kamera minimap langsung pindah mengikuti batas baru
		camera_2d.reset_smoothing()
		camera_2d.force_update_scroll()

func change_quest_target(new_target: Node2D) -> void:
	quest_target = new_target
