extends Node3D

# Each camera position has a location AND a rotation
@export var center_position: Vector3 
@export var center_rotation_y: float 

@export var left_position: Vector3 
@export var left_rotation_y: float

@export var right_position: Vector3 
@export var right_rotation_y: float

@export var edge_threshold: float = 50.0
@export var pan_speed: float = 5.0
@export var step_cooldown: float = 0.6

enum CameraPosition { LEFT, CENTER, RIGHT }
var current_position: CameraPosition = CameraPosition.CENTER
var target_pos: Vector3 = Vector3.ZERO
var target_rot: float = 0.0
var cooldown_timer: float = 0.0

func _ready():
	target_pos = center_position
	target_rot = center_rotation_y

func _process(delta):
	global_position = lerp(global_position, target_pos, pan_speed * delta)
	rotation_degrees.y = lerp(rotation_degrees.y, target_rot, pan_speed * delta)
	
	if cooldown_timer > 0.0:
		cooldown_timer -= delta
		return
	
	_check_mouse_position()

func _check_mouse_position():
	var mouse_pos = get_viewport().get_mouse_position()
	var screen_size = get_viewport().get_visible_rect().size
	
	var on_left_edge = mouse_pos.x <= edge_threshold
	var on_right_edge = mouse_pos.x >= screen_size.x - edge_threshold

	if on_left_edge:
		match current_position:
			CameraPosition.RIGHT:
				set_camera_position(CameraPosition.CENTER)
			CameraPosition.CENTER:
				set_camera_position(CameraPosition.LEFT)
			# Already LEFT, do nothing
	
	elif on_right_edge:
		match current_position:
			CameraPosition.LEFT:
				set_camera_position(CameraPosition.CENTER)
			CameraPosition.CENTER:
				set_camera_position(CameraPosition.RIGHT)
			# Already RIGHT, do nothing

func set_camera_position(new_pos: CameraPosition):
	current_position = new_pos
	match new_pos:
		CameraPosition.LEFT:
			target_pos = left_position
			target_rot = left_rotation_y
		CameraPosition.CENTER:
			target_pos = center_position
			target_rot = center_rotation_y
		CameraPosition.RIGHT:
			target_pos = right_position
			target_rot = right_rotation_y
	cooldown_timer = step_cooldown

func get_current_camera_position() -> CameraPosition:
	return current_position
