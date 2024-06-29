extends EnemyBase

@export var _hitbox_list : Array[Hitbox]

var speed = 0
var hp = 10
var rand_t = 0

var stagger = 0

func _ready():
	speed = 1
	for h in _hitbox_list:
		h.connect("hit", on_hit)
	GameManager.register_enemy($"BoneAttachment3D")

func on_hit(body):
	print(body.get_parent().name)
	if(body.get_parent() is Player):
		body.get_parent().hurt(damage,$Body.global_rotation)
	print(damage)
	

func hit_stop():
	pass 

	
func hurt(damage,r):
	stagger += damage * 20
	if(!disabledMovement):
		disable_movement()
		$HitSFX.pitch_scale = randf_range(0.9,1.1)
		$HitSFX.play()
		$Body.rotation = Vector3(r.x,r.y+3.14,r.z)
		hp -= damage
		if(hp <= 0):
			$AnimationTree.set("parameters/conditions/death",true)
			$AnimationTree["parameters/playback"].travel("Knockback")
			$AnimationTree.set("parameters/conditions/attack",false)
		else:
			if(stagger > 100):
				$AnimationTree["parameters/playback"].travel("Knockback")
				$AnimationTree.set("parameters/conditions/attack",false)
				stagger = 0
			else:
				enable_movement()
		rand_t = randf_range(8,12) * 0.01
		Engine.time_scale = rand_t
		await get_tree().create_timer(0.1*0.1).timeout
		if(Engine.time_scale == rand_t):
			Engine.time_scale = 1

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

func _process(delta):
	stagger -= delta
	$"Control/ProgressBar".value = stagger
	if(!disabledMovement):
		var distance = GameManager.player.global_position- $Body.global_position
		var i = distance.normalized()
		var input = Vector2(i.z,i.x).normalized()
		
		if(distance.length() > 10 && distance.length() < 20):
			$AnimationTree.set("parameters/conditions/attack",true)
		elif(distance.length() < 10):
			speed = 0
			$AnimationTree.set("parameters/conditions/attack",false)
		else:
			speed = 1
			$AnimationTree.set("parameters/conditions/attack",false)
			
		$AnimationTree.set("parameters/BlendSpace2D/blend_position",Vector2(0, speed))
		$Body.global_rotation = Vector3(0,input.angle(),0)
		
	var current_rotation = $Body.get_quaternion()
	var velocity: Vector3 = current_rotation * $AnimationTree.get_root_motion_position() / delta
	velocity = Vector3(velocity.x * $Body/snek.scale.x, 0, velocity.z * $Body/snek.scale.x)
	$Body.set_velocity(velocity)
	$Body.move_and_slide()
