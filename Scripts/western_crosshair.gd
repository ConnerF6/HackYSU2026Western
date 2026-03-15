extends Sprite2D

@export var edge_threshold: float = 50.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(_delta):
	var mouse_pos = get_viewport().get_mouse_position()
	var screen_size = get_viewport().get_visible_rect().size
	
	# Follow the mouse
	position = mouse_pos
	
	# Hide on screen edges (camera pan zones)
	if mouse_pos.x <= edge_threshold or mouse_pos.x >= screen_size.x - edge_threshold:
		visible = false
	else:
		visible = true
