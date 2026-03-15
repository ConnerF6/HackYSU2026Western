extends Node3D

@export var press_rotation: float = 45.0
@export var press_speed: float = 0.15
@export var cooldown_time: float = 2.0
@export var camera_side: String = "left"  # Set to "left" or "right" in Inspector

@onready var lever_pivot = $SwitchPivot
@onready var click_area = $ClickArea
@onready var flash_overlay = get_node("/root/Game/CameraRig/CanvasLayer/FlashOverlay")
@onready var breaker_audio = $AudioStreamPlayer3D

var is_cooling_down: bool = false
var start_rotation_z: float

signal beacon_flashed

func _ready():
	start_rotation_z = lever_pivot.rotation_degrees.z

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("Click detected")
			if is_cooling_down:
				print("On cooldown, ignoring")
				return
			var cam_rig = get_node("/root/Game/CameraRig")
			var current_side = cam_rig.get_current_camera_position()
			print("Current camera side: ", current_side, " | Expected: ", camera_side)
			var correct_side = (
				(camera_side == "left" and current_side == cam_rig.CameraPosition.LEFT) or
				(camera_side == "right" and current_side == cam_rig.CameraPosition.RIGHT)
			)
			if not correct_side:
				print("Wrong camera side, ignoring")
				return
			var camera = get_viewport().get_camera_3d()
			var mouse_pos = get_viewport().get_mouse_position()
			var ray_origin = camera.project_ray_origin(mouse_pos)
			var ray_direction = camera.project_ray_normal(mouse_pos)
			var space_state = get_world_3d().direct_space_state
			var query = PhysicsRayQueryParameters3D.create(
				ray_origin,
				ray_origin + ray_direction * 100.0
			)
			var result = space_state.intersect_ray(query)
			print("Raycast result: ", result)
			if result:
				print("Hit collider: ", result.collider)
				print("Expected: ", click_area)
			if result and result.collider == click_area:
				_press()
func _press():
	is_cooling_down = true
	emit_signal("beacon_flashed")
	flash_overlay.flash()
	breaker_audio.play()
	# Slam lever down
	var press_tween = create_tween()
	press_tween.set_ease(Tween.EASE_OUT)
	press_tween.set_trans(Tween.TRANS_SINE)
	press_tween.tween_property(lever_pivot, "rotation_degrees:z",
		start_rotation_z - press_rotation, press_speed)
	await press_tween.finished
	# Slowly return back up
	var return_tween = create_tween()
	return_tween.set_ease(Tween.EASE_IN_OUT)
	return_tween.set_trans(Tween.TRANS_SINE)
	return_tween.tween_property(lever_pivot, "rotation_degrees:z",
		start_rotation_z, cooldown_time)
	await return_tween.finished
	is_cooling_down = false
