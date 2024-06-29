extends Node3D

@onready var ANIMATION_TREE : AnimationTree = $AnimationTree

var target_position = null
var target_rotation = null

var collision_layer = 32

var clothes = null

func showClothes():
	var ch = GameManager.clothing
	if(clothes != null):
		ch = clothes
	for k in ch.keys():
		var c = $skate/Armature/Skeleton3D.find_child(k)
		if(c != null):
			if(ch[k]):
				c.show()
			else:
				c.hide()

func _ready():
	showClothes()

func _process(delta):
	if(target_position != null && target_rotation != null):
		position = lerp(position, target_position, max(delta * GameManager.player.MP_INTERPOLATION_SPEED,1))  
		rotation = Quaternion.from_euler(rotation).slerp(Quaternion.from_euler(target_rotation),max(delta * GameManager.player.MP_INTERPOLATION_SPEED,1)).get_euler()

func enable_collisions():
	pass
		
func disable_collisions():
	pass
