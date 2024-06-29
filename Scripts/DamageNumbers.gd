extends Label3D

var dmg : int


func _ready():
	text = str(dmg)
	pass 
	
var acc = 0;
func _process(delta):
	acc += delta * 0.2
	if(acc > 1.0):
		queue_free()
	modulate = Color(1,1,1,1.0 - acc)
	outline_modulate = Color(0,0,0,1.0 - acc)
	pass
