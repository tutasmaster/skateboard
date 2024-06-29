extends Node3D
class_name Player

@export var hp_panel : Panel
@onready var body = $CharacterBody3D
@export var _hitbox_list : Array[Hitbox]

var hp = 10;

# Called when the node enters the scene tree for the first time.
func _ready():
	hp_panel.custom_minimum_size = Vector2(hp*50,30)
	hp_panel.update_minimum_size()
	GameManager.playerScript = self
	GameManager.player = body
	for h in _hitbox_list:
		h.connect("hit", on_hit)
	pass # Replace with function body.

var damage = 2

func on_hit(body):
	print(body.get_parent().name)
	if(body.get_parent() is EnemyBase):
		var pos = ($CharacterBody3D.global_position - body.global_position).normalized()
		var dir = Vector2(pos.z,pos.x).angle()
		body.get_parent().hurt(damage,Vector3(0,dir + 3.14,0))
	print(damage)

var cur_angle = 0

func hurt(damage,r):
	if(!disabledMovement):
		hp -= damage
		hp_panel.custom_minimum_size = Vector2(hp*50,30)
		hp_panel.update_minimum_size()
		if(hp <= 0):
			GameManager.reload()
		disable_movement()
		$CharacterBody3D.rotation = Vector3(r.x,r.y+3.14,r.z)
		$AnimationTree["parameters/playback"].travel("Knockback")

var inputVel = Vector2()

func disable_movement():
	inputVel = Vector2(0,0)
	disabledMovement = true
	
func enable_movement():
	disabledMovement = false
var disabledMovement = false

func play_hit():
	$HitSFX.pitch_scale = randf_range(0.8,1.2)
	$HitSFX.play()

func hit_stop():
	pass
var is_grounded = true
var hang_time = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var current_rotation = $CharacterBody3D.get_quaternion()
	var velocity: Vector3 = current_rotation * $AnimationTree.get_root_motion_position() / delta
	var f = $CharacterBody3D.get_floor_normal()
	if(f == Vector3.ZERO):
		f = Vector3.UP
	var cb : CharacterBody3D = $CharacterBody3D
	cur_gravity -= 9.8 * delta
	if $CharacterBody3D.is_on_floor():
		cur_gravity = 0
	var grav : Vector3 = f * cur_gravity
	velocity += grav
	$CharacterBody3D.set_velocity(velocity)
	$CharacterBody3D.move_and_slide()
	
	$AnimationTree.set("parameters/BlendTree/Blend2/blend_amount", 0 if $CharacterBody3D.is_on_floor() || hang_time < 0.1 else 1)
	
	if(!is_grounded && $CharacterBody3D.is_on_floor() && hang_time > 0.5):
		$AnimationTree.set("parameters/BlendTree/OneShot/request", true)
	if(!$CharacterBody3D.is_on_floor()):
		hang_time += delta
	else:
		hang_time = 0
	is_grounded = $CharacterBody3D.is_on_floor()
	if(!disabledMovement):
		var camera_rotation = GameManager.camera.global_rotation.y + (3.14/2)
		var mult = 1
		if(Input.is_action_pressed("roll")):
			mult = 2
		inputVel = inputVel.lerp(Vector2(Input.get_axis("left","right"),Input.get_axis("down","up"))*mult,delta*4)
		var inputDir = inputVel.normalized()
		var inputPow = clamp(inputVel.length(),0,2)
		inputVel = inputDir * inputPow
		#print(inputVel)
		$AnimationTree.set("parameters/BlendTree/BlendSpace1D/blend_position", 0)
		if(inputPow > 0.1):
			
			$CharacterBody3D.rotation = Vector3(0,inputDir.angle()+camera_rotation,0)
			$AnimationTree.set("parameters/BlendTree/BlendSpace1D/blend_position", inputVel.length())
			#if(Input.is_action_just_pressed("roll")):
				#$AnimationTree["parameters/playback"].travel("Roll");
				#disable_movement()
				#$AnimationTree.set("parameters/BlendSpace2D/blend_position", Vector2(0,inputVel.length()*2))
		if(Input.is_action_just_pressed("attack_light")):
			$AnimationTree["parameters/playback"].travel("Attack")
			pass
		elif(Input.is_action_just_pressed("attack_heavy")):
			$AnimationTree["parameters/playback"].travel("Attack2")
			pass
	$CharacterBody3D.quaternion = $CharacterBody3D.quaternion * $AnimationTree.get_root_motion_rotation()
	pass

var cur_gravity = 0

var target : Node3D = null

func _input(e : InputEvent):
	if(e is InputEventJoypadButton && e.pressed && e.is_action("target")):
		if(target != null):
			target = null
			return
		var potential : Array[Node3D] = []
		for t in GameManager._targets:
			if(t == null):
				continue
			var b : Node3D = t
			var pos2d = GameManager.camera.unproject_position(b.global_position)
			if(pos2d.x > 0 && pos2d.y > 0 && 
				pos2d.x < get_viewport().size.x && pos2d.y < get_viewport().size.y && 
				!GameManager.camera.is_position_behind(b.global_position)):
				potential.push_back(b)
				pass
			
		var lowest_target = null
		var distance_to_center = 10000
		for p in potential:
			var b : Node3D = p
			var pos : Vector2 = GameManager.camera.unproject_position(b.global_position)
			var center = get_viewport().size/2
			var distance = pos.distance_to(center)
			if(distance < distance_to_center):
				lowest_target = b
				distance_to_center = distance
		target = lowest_target
		print(target)
