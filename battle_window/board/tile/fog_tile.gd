extends ColorRect
class_name FogTile

func _ready() -> void:
	color = Color(0, 0, 0, 0.75)

func set_fog_visible(visible: bool):
	color.a = 0.0 if visible else 0.75
