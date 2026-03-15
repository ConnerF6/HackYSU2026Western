extends Node

@export var time_limit: float = 90.0
@export var targets_needed: int = 30
@export var threat_check_interval: float = 5.0
@export var base_threat_chance: float = 0.20
@export var threat_chance_per_hit: float = 0.01

var time_remaining: float
var targets_hit: int = 0
var game_active: bool = false
var threats_enabled: bool = false
var threat_timer: float = 0.0

@onready var left_threat = get_node("/root/Game/Zombie")
@onready var right_threat = get_node("/root/Game/Rat")
@onready var left_breaker = get_node("/root/Game/LeftBreaker/BreakerPrt2")
@onready var right_breaker = get_node("/root/Game/RightBreaker/BreakerPrt2")

func _ready():
	time_remaining = time_limit
	# Connect targets
	for target in get_tree().get_nodes_in_group("Targets"):
		target.target_hit.connect(_on_target_hit)
	# Connect threats
	left_threat.threat_failed.connect(_on_threat_failed)
	right_threat.threat_failed.connect(_on_threat_failed)
	# Connect breakers
	left_breaker.beacon_flashed.connect(_on_beacon_flashed.bind("left"))
	right_breaker.beacon_flashed.connect(_on_beacon_flashed.bind("right"))
	left_threat.visible = false
	right_threat.visible = false
	game_active = true
	print("Game started! Hit ", targets_needed, " targets in ", time_limit, " seconds!")

func _process(delta):
	if not game_active:
		return
	time_remaining -= delta
	if time_remaining <= 0:
		time_remaining = 0
		_lose()
		return
	if threats_enabled:
		threat_timer += delta
		if threat_timer >= threat_check_interval:
			threat_timer = 0.0
			_roll_threats()

func _roll_threats():
	var chance = clamp(base_threat_chance + (threat_chance_per_hit * targets_hit), 0.0, 1.0)
	print("Rolling threats, chance: ", int(chance * 100), "%")
	if not left_threat.is_active and randf() < chance:
		left_threat.activate()
	if not right_threat.is_active and randf() < chance:
		right_threat.activate()

func _on_beacon_flashed(side: String):
	print("Beacon flashed on side: ", side)
	if side == "left":
		left_threat.flash()
	elif side == "right":
		right_threat.flash()

func _on_target_hit():
	if not game_active:
		return
	targets_hit += 1
	print("Targets hit: ", targets_hit, " / ", targets_needed)
	if targets_hit >= 5 and not threats_enabled:
		threats_enabled = true
		print("Threats are now active!")
	if targets_hit >= targets_needed:
		_win()

func _on_threat_failed():
	_jumpscare()

func _lose():
	game_active = false
	DeathReason.reason = "Took too long..."
	get_tree().change_scene_to_file("res://Scenes/death_screen.tscn")

func _jumpscare():
	game_active = false
	DeathReason.reason = "You got shot!"
	get_tree().change_scene_to_file("res://Scenes/death_screen.tscn")

func _win():
	game_active = false
	# We can add a win screen later, for now back to title
	get_tree().change_scene_to_file("res://Scenes/title_screen.tscn")
