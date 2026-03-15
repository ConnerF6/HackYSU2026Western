extends Control

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$CanvasLayer/ColorRect/Label.text = DeathReason.reason
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://Scenes/title_screen.tscn")
