extends RigidBody3D

@export var despawn_time: float = 4.0
@export var ball_speed: float = 40.0

func _ready():
	# Continuous collision detection prevents tunneling at high speeds
	continuous_cd = true

func launch(direction: Vector3):
	linear_velocity = direction * ball_speed
	await get_tree().create_timer(despawn_time).timeout
	queue_free()
