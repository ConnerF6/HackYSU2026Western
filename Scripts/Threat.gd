extends Node3D

@export var min_time: float = 7.0
@export var max_time: float = 10.0

@onready var audio = $AudioStreamPlayer3D

var is_active: bool = false
var time_remaining: float = 0.0

signal threat_failed
signal threat_retreated

func _ready():
	visible = false

func _process(delta):
	if not is_active:
		return
	time_remaining -= delta
	if time_remaining <= 0:
		_fail()

func activate():
	if is_active:
		return
	is_active = true
	time_remaining = randf_range(min_time, max_time)
	visible = true
	audio.play()
	print("Threat appeared: ", name)

func flash():
	if not is_active:
		return
	is_active = false
	visible = false
	audio.stop()
	emit_signal("threat_retreated")
	print("Threat retreated: ", name)

func _fail():
	is_active = false
	visible = false
	audio.stop()
	emit_signal("threat_failed")
	print("Threat attacked: ", name)
