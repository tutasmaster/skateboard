extends Camera3D

var offset : Vector3 = Vector3.ZERO
var offset_r : Vector3 = Vector3.ZERO
@export var node : Node3D
var target_camera : Camera3D

func _ready():
	GameManager.camera = self
	offset = global_position - node.global_position
	offset_r = global_rotation

func _process(delta):
	
	if(target_camera == null):
		global_position = global_position.slerp(node.global_position + offset,delta * 4)
		global_rotation = global_rotation.slerp(offset_r,delta * 4)
		return
	
	global_position = global_position.slerp(target_camera.global_position,delta * 4)
	global_rotation = global_rotation.slerp(target_camera.global_rotation,delta * 4)
	fov = lerp(fov,target_camera.fov,delta * 4)
	
