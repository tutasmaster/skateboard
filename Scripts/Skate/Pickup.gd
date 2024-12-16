extends Node3D

func _ready():
	var area : Area3D = $Area3D

func _process(delta: float) -> void:
	rotation.y += delta * 3

func _on_area_3d_area_entered(area: Area3D) -> void:
	print(area)
	queue_free()
