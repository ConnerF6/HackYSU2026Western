extends Node3D

@export var min_z: float = -11.0
@export var max_z: float = 6.5
@export var move_duration: float = 2.0
@export var speed : float
@export var reset_time: float = 1.5
@export var start_at_max: bool = false

var is_knocked_down: bool = false
var tween: Tween

signal target_hit

func _ready():
	position.z = max_z if start_at_max else min_z
	_start_moving()

func _start_moving():
	if is_knocked_down:
		return
	tween = create_tween()
	tween.set_loops()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	# Higher multiplier = shorter duration = faster movement
	var adjusted_duration = move_duration * 2 / speed
	tween.tween_property(self, "position:z", max_z, adjusted_duration)
	tween.tween_property(self, "position:z", min_z, adjusted_duration)

func knock_down():
	if is_knocked_down:
		return
	is_knocked_down = true
	tween.kill()
	emit_signal("target_hit")
	var knock_tween = create_tween()
	knock_tween.set_ease(Tween.EASE_OUT)
	knock_tween.set_trans(Tween.TRANS_BOUNCE)
	knock_tween.tween_property(self, "rotation_degrees:x", 90.0, 0.3)
	await get_tree().create_timer(reset_time).timeout
	_reset()

func _reset():
	var reset_tween = create_tween()
	reset_tween.tween_property(self, "rotation_degrees:x", 0.0, 0.2)
	await reset_tween.finished
	is_knocked_down = false
	position.z = min_z
	_start_moving()
