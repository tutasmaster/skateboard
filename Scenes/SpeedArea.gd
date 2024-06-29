extends Area3D

@export var velocity : Vector3 = Vector3(0,0,0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if(overlaps_area(GameManager.player.area)):
		if(GameManager.player.state == Wooper.STATE.airborne):
			GameManager.player.velocity += velocity * delta
	pass
