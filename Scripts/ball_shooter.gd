extends Node3D

@export var ball_scene: PackedScene
@export var fire_cooldown: float = 0.5

@onready var spawn_point = $Marker3D
@onready var cam_rig = get_node("/root/Game/CameraRig")
@onready var gun_model = self
@onready var gun_audio = $AudioStreamPlayer3D

var can_fire: bool = true
var is_active: bool = true
var start_position: Vector3

func _ready():
	start_position = gun_model.position

func _process(_delta):
	var current_side = cam_rig.get_current_camera_position()
	if current_side == cam_rig.CameraPosition.CENTER:
		_activate()
	else:
		_deactivate()

func _activate():
	if is_active:
		return
	is_active = true
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(gun_model, "position", start_position, 0.3)

func _deactivate():
	if not is_active:
		return
	is_active = false
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(gun_model, "position",
		start_position + Vector3(0, -0.5, 0), 0.3)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and can_fire and is_active:
			var mouse_pos = get_viewport().get_mouse_position()
			var screen_size = get_viewport().get_visible_rect().size
			if mouse_pos.x <= 50 or mouse_pos.x >= screen_size.x - 50:
				return
			_fire()

func _fire():
	can_fire = false
	gun_audio.play()
	var ball = ball_scene.instantiate()
	get_tree().root.add_child(ball)
	ball.global_position = spawn_point.global_position
	var cam = get_viewport().get_camera_3d()
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_direction = cam.project_ray_normal(mouse_pos)
	ball.launch(ray_direction)
	await get_tree().create_timer(fire_cooldown).timeout
	can_fire = true
