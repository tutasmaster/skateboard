extends EnemyBase

@export var _hitbox_list : Array[Hitbox]
@export var anim : AnimationTree
var speed = 0

func _ready():
	speed = randf_range(0.05,0.4)
	for h in _hitbox_list:
		h.connect("hit", on_hit)

func on_hit(body):
	print(body.get_parent().name)
	if(body.get_parent() is Player):
		body.get_parent().hurt(damage,$Body.global_rotation)
	print(damage)
	
var hp = 10

func hit_stop():
	pass 

var rand_t = 0
	
func hurt(damage,r):
	if(!disabledMovement):
		disable_movement()

func play_hit():
	pass

func death():
	$Body/CollisionShape3D.disabled = true
	queue_free()

func disable_movement():
	disabledMovement = true
	
func enable_movement():
	disabledMovement = false
	
var disabledMovement = false

var anim_time : float = 0

func _process(delta):
	anim_time += delta
	var hill : float = 0.0
	if(GameManager.player != null and !disabledMovement):
		var distance : Vector3 = GameManager.player.global_position - $Body.global_position
		hill = 1
		var stop = false
		if(distance.length() > 15):
			hill = 0
			anim.set("parameters/conditions/Leap", false)
			stop = true
		elif(distance.length() > 2 && anim_time > 0.1):
			anim_time = 0
			anim.set("parameters/conditions/Leap", true)
		else:
			anim.set("parameters/conditions/Leap", false)
			anim_time = 0
			
		if !stop:
			var i = distance.normalized()
			var input = Vector2(i.z,i.x).normalized()
			$Body.global_rotation = Vector3(0,input.angle(),0)
	
	var cur = lerp($AnimationTree["parameters/BlendSpace1D/blend_position"],hill,delta)
	anim.set("parameters/BlendSpace1D/blend_position",cur)
	var current_rotation = $Body.get_quaternion()
	var velocity: Vector3 = current_rotation * $AnimationTree.get_root_motion_position() * $Body/Zombie_reference.scale.x / delta
	velocity = Vector3(velocity.x, 0, velocity.z)
	$Body.velocity.x = velocity.x
	$Body.velocity.z = velocity.z
	$Body.set_velocity(velocity)

func _physics_process(delta):
	if not $Body.is_on_floor():
		$Body.velocity.y -= 9.8 * delta * 10
	$Body.move_and_slide()
