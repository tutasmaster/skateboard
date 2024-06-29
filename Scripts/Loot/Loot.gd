extends Area3D

var vel : Vector2 = Vector2.ZERO
var bounce = 1.0
var original : Vector3 = Vector3.ZERO

func _ready():
	original = global_position

func _on_body_entered(body):
	if(body.get_parent() is Player):
		print("Loot Collected")
		GameManager.play_loot_sound()
		queue_free()

var acc = 0.0

func _physics_process(delta):
	acc += delta
	var v = 1.0 - delta
	v *= v
	vel *= v
	
	var b = sin(acc*5.0) / (acc*5.0)
	
	global_position += Vector3(vel.x,0,vel.y)
	global_position.y = original.y + b
