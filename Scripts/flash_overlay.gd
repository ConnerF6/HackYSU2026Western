extends ColorRect

@export var flash_duration: float = 0.3  # How long the flash lasts
@export var peak_opacity: float = 0.9    # How bright the flash is (0-1)

func _ready():
	modulate.a = 0.0  # Start invisible
	mouse_filter = Control.MOUSE_FILTER_IGNORE  # Don't block clicks

func flash():
	var tween = create_tween()
	# Slam to full brightness instantly
	tween.tween_property(self, "modulate:a", peak_opacity, 0.05)
	# Fade out slowly
	tween.tween_property(self, "modulate:a", 0.0, flash_duration)
