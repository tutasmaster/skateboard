extends Area3D

@onready var _cam = $"Camera3D"

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(_body_entered)
	body_exited.connect(_body_exited)
	
func _body_entered(body: Node3D):
	if(body.get_parent() is Player):
		GameManager.camera.target_camera = _cam

func _body_exited(body: Node3D):
	if(body.get_parent() is Player):
		if(GameManager.camera.target_camera == _cam):
			GameManager.camera.target_camera = null
