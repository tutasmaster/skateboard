extends Node3D
class_name Hitbox

signal hit

func _ready():
	$Area3D.body_entered.connect(on_hit)
	disable_box()

func enable_box():
	$Area3D.monitoring = true
	$Area3D.body_entered.connect(on_hit)
	$Area3D/CollisionShape3D/MeshInstance3D.visible = true
	
func enable_box_debug():
	enable_box()
	#$Area3D/MeshInstance3D.visible = true
	
func disable_box():
	$Area3D.monitoring = false
	$Area3D.body_entered.disconnect(on_hit)
	$Area3D/CollisionShape3D/MeshInstance3D.visible = false
	
func disable_box_debug():
	disable_box()
	#$Area3D/MeshInstance3D.visible = false
	
func on_hit(body):
	emit_signal("hit",body)
	get_parent().play_hit()
