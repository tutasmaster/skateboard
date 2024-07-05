extends Node3D

@export var target : Node3D;

func _ready():
	GameManager.camera = $"SpringArm3D/Camera3D"
	pass


func _process(delta):
	
	var distance = 2.0
	distance += GameManager.player.velocity.length()/GameManager.player.SPEED_CAP*2
	var fov = 76
	fov += GameManager.player.velocity.length()/GameManager.player.SPEED_CAP*5
	if(GameManager.playerScript != null && GameManager.playerScript.target != null):
		var difference = (GameManager.playerScript.target.global_position - GameManager.player.global_position)/2
		look_at(GameManager.playerScript.target.global_position - difference,Vector3.UP)
		rotation.x = 0
		return
	#var cameraVel = Vector2(
		#Input.get_axis("camera_left","camera_right") * 0.7 + 
		#(Input.get_axis("left", "right") * (Input.get_axis("up", "down") + 1)*0.5) * 0.30
		#,Input.get_axis("camera_up","camera_down"))
	if(target.state == Wooper.STATE.vert):
		distance = 2.0
		distance += GameManager.player.vert_vel.length()/GameManager.player.SPEED_CAP*2
		var angle = target.get_vert_plane_angle()
		var angle_float = atan2(angle.basis.z.z,angle.basis.z.x)
		$SpringArm3D.rotation = Quaternion.from_euler($SpringArm3D.rotation).slerp(Quaternion.from_euler(-Vector3(PI/2,target.vert_angle_offset if target.vert_side == 0 else -target.vert_angle_offset,0)),delta*3).get_euler()
		global_position = target.global_position
		global_rotation = Quaternion.from_euler(global_rotation).slerp(Quaternion(Vector3.UP,target.get_vert_plane_angle().basis.y),delta*3).get_euler()
		#global_rotation = Quaternion(target.vert.basis.z,Vector3.DOWN).get_euler()
		#global_rotation = Quaternion.from_euler(global_rotation).slerp(Quaternion.from_euler(target.rotation),delta*3).get_euler()
		#global_rotation = Quaternion(Vector3.DOWN,PI).get_euler()
		#look_at(target.global_position)
	elif(target.state == Wooper.STATE.grounded):
		var angle = 0
		$SpringArm3D.rotation = Quaternion.from_euler($SpringArm3D.rotation).slerp(Quaternion.from_euler(-Vector3(0.3,PI,0)),delta*3).get_euler()
		var rot = target.rotation
		if(GameManager.player.velocity.z < -0.5):
			rot = target.BACKWARDS.global_rotation
		global_rotation = Quaternion.from_euler(global_rotation).slerp(Quaternion.from_euler(rot),delta*3).get_euler()
		global_position = target.position
	elif(target.state != Wooper.STATE.airborne):
		$SpringArm3D.rotation = Quaternion.from_euler($SpringArm3D.rotation).slerp(Quaternion.from_euler(-Vector3(0.3,PI,0)),delta*3).get_euler()
		global_rotation = Quaternion.from_euler(global_rotation).slerp(Quaternion.from_euler(target.rotation),delta*3).get_euler()
		global_position = target.position
	else:
		$SpringArm3D.rotation = Vector3(-0.3,PI,0)
		global_rotation.z = 0
		global_position = target.position
	#rotate_y(-cameraVel.x*delta*2)
	
	$SpringArm3D.spring_length = lerp($SpringArm3D.spring_length, distance, min(1,delta * 3))
	GameManager.camera.fov = lerp(GameManager.camera.fov,fov,min(1,delta * 3))
	pass
