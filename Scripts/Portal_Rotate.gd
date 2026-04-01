extends Sprite2D

@export var rotation_speed_degrees: float = -180


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotation += deg_to_rad(rotation_speed_degrees) * delta
