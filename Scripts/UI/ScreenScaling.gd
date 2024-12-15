extends Node2D

@export var baseSize : Vector2i = Vector2i(1152, 648)

func _process(delta: float) -> void:
	scale = (Vector2(get_viewport().size) / Vector2(baseSize))
