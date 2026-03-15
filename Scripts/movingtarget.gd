extends Node3D

@export var min_z: float = -11.0
@export var max_z: float = 6.5
@export var move_duration: float = 5.0
@export var speed: float = 1.0
@export var reset_time: float = 1.5
@export var start_at_max: bool = false
@export var knocked_down_y: float = -2.0
@onready var hit_audio = $AudioStreamPlayer3D

var is_knocked_down: bool = false
var start_y: float
var time: float = 0.0

signal target_hit

func _ready():
	start_y = position.y
	# Start at different points in the cycle to desync targets
	time = 0.0 if not start_at_max else PI
	$Area3D.body_entered.connect(_on_body_entered)

func _process(delta):
	if is_knocked_down:
		return
	time += delta * speed
	# Sine wave between min_z and max_z
	var mid = (max_z + min_z) / 2.0
	var amplitude = (max_z - min_z) / 2.0
	position.z = mid + sin(time / move_duration * PI) * amplitude

func _on_body_entered(body):
	if body is RigidBody3D:
		knock_down()

func knock_down():
	if is_knocked_down:
		return
	is_knocked_down = true
	hit_audio.play()
	emit_signal("target_hit")
	var knock_tween = create_tween()
	knock_tween.set_ease(Tween.EASE_OUT)
	knock_tween.set_trans(Tween.TRANS_SINE)
	knock_tween.tween_property(self, "position:y", knocked_down_y, 0.3)
	await knock_tween.finished
	await get_tree().create_timer(reset_time).timeout
	_reset()

func _reset():
	var reset_tween = create_tween()
	reset_tween.set_ease(Tween.EASE_OUT)
	reset_tween.set_trans(Tween.TRANS_SINE)
	reset_tween.tween_property(self, "position:y", start_y, 0.2)
	await reset_tween.finished
	is_knocked_down = false
