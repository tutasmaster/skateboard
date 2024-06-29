extends EnemyBase

func on_hit(body):
	print(body.get_parent().name)
	if(body.get_parent() is Player):
		body.get_parent().hurt(damage,$Body.global_rotation)
	print(damage)
	
@export var hp = 6

func hit_stop():
	pass 

var rand_t = 0
	
func hurt(damage,r):
	var l = GameManager.dmg_num.instantiate()
	var s = Vector2(randf_range(-0.5,0.5),randf_range(-0.25,0.25))
	l.global_position = $Body.global_position + Vector3(s.x,0,s.y)
	l.dmg = damage
	get_parent().add_child(l)
	hp -= l.dmg
	if hp <= 0:
		if(!disabledMovement):
			disable_movement()

func play_hit():
	pass

func death():
	$Body/CollisionShape3D.disabled = true
	queue_free()

func disable_movement():
	disabledMovement = true
	for x in range(10):
		var l = GameManager.loot.instantiate()
		var s = Vector2(randf_range(-0.5,0.5),randf_range(-0.5,0.5))
		l.global_position = $Body.global_position + Vector3(s.x,0,s.y)
		l.vel = s * 0.05
		get_parent().add_child(l)
	queue_free()
	
func enable_movement():
	disabledMovement = false
	
var disabledMovement = false

func _process(delta):
	pass

func _physics_process(delta):
	if not $Body.is_on_floor():
		$Body.velocity.y -= 9.8 * delta * 10
	$Body.move_and_slide()
