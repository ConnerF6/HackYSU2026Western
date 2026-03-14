extends Node3D

@export var min_z: float = -8.0
@export var max_z: float = 7.0
@export var move_duration: float = 4.0
@export var speed_multiplier: float = 1.0
@export var stutter_chance: float = 0.6
@export var start_at_max: bool = false  # Set one to true to desync them

var moving_to_max: bool = true

func _ready():
	position.z = max_z if start_at_max else min_z
	moving_to_max = !start_at_max
	_begin_next_sweep()

func _begin_next_sweep():
	var next_z = max_z if moving_to_max else min_z
	var adjusted_duration = move_duration / speed_multiplier

	if randf() < stutter_chance:
		# Stutter: move partway, pause briefly, then continue
		var midpoint = position.z + (next_z - position.z) * randf_range(0.3, 0.7)
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(self, "position:z", midpoint, adjusted_duration * 0.4)
		tween.tween_interval(randf_range(0.1, 0.3))  # Brief pause
		tween.tween_property(self, "position:z", next_z, adjusted_duration * 0.6)
		await tween.finished
	else:
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(self, "position:z", next_z, adjusted_duration)
		await tween.finished

	moving_to_max = !moving_to_max
	_begin_next_sweep()
