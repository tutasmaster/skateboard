extends Node3D

@export var target : Node3D;

func _ready():
	GameManager.camera = $"SpringArm3D/Camera3D"
	pass


func _process(delta):
	global_position = global_position.lerp(target.position, delta*7.5)
	if(GameManager.playerScript != null && GameManager.playerScript.target != null):
		var difference = (GameManager.playerScript.target.global_position - GameManager.player.global_position)/2
		look_at(GameManager.playerScript.target.global_position - difference,Vector3.UP)
		rotation.x = 0
		return
	rotation.x = 0
	rotation.z = 0
	var cameraVel = Vector2(
		Input.get_axis("camera_left","camera_right") * 0.7 + 
		(Input.get_axis("left", "right") * (Input.get_axis("up", "down") + 1)*0.5) * 0.30
		,Input.get_axis("camera_up","camera_down"))
	rotate_y(-cameraVel.x*delta*2)
	
	
	pass
