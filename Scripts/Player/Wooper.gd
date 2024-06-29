extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var vel = 0
var angle = 0

var trail : Array[Vector3] = []

@onready var raycast : RayCast3D = $"CollisionShape3D/RayCast3D"
@onready var raycast_secondary : RayCast3D = $"CollisionShape3D/TargetRotation/Angle"
@onready var raycast_secondary_2 : RayCast3D = $"CollisionShape3D/TargetRotation/Angle2"
@onready var target_rotation : Node3D = $"CollisionShape3D/TargetRotation"

func is_air_borne():
	var r = raycast_secondary if vel >= 0 else raycast_secondary_2;
	if(!r.is_colliding()):
		r = raycast
	return !r.is_colliding()

var last_delta = 0
var last_drag = 0
var last_friction = 0

func _process(delta):
	trail.push_back(position + target_rotation.basis.y)
	if(trail.size() > 200):
		trail.pop_front()
	DebugDraw3D.draw_line_path(trail,Color.WHITE)
	DebugDraw2D.set_text("gravity_raycast", raycast.is_colliding(), 0, Color.RED if raycast.is_colliding() else Color.WHITE)
	DebugDraw2D.set_text("forward_raycast", raycast_secondary.is_colliding(), 0, Color.RED if raycast_secondary.is_colliding() else Color.WHITE)
	DebugDraw2D.set_text("backward_raycast", raycast_secondary_2.is_colliding(), 0, Color.RED if raycast_secondary_2.is_colliding() else Color.WHITE)
	var input = Input.get_axis("down", "up")
	DebugDraw2D.set_text("input", input,0,Color.GREEN if input >= 0 else Color.RED )
	DebugDraw3D.draw_arrow(position + transform.basis.y * 2, 
	position + transform.basis.y * 2 + target_rotation.basis.y*2,
	Color.WHITE, 0.1)
	DebugDraw3D.draw_arrow(position + transform.basis.y * 2, 
	position + transform.basis.y * 2 + target_rotation.basis.z*vel * 0.5,
	Color.RED, 0.1)
	#DebugDraw3D.draw_arrow(position + transform.basis.y * 2, 
	#position + transform.basis.y * 2 + target_rotation.basis.z*Input.get_axis("down","up"),
	#Color.BLUE, 0.1)
	DebugDraw3D.draw_arrow(position + transform.basis.y * 2, 
	position + transform.basis.y * 2 + target_rotation.basis.z*-last_friction*50,
	Color.GREEN, 0.1)
	DebugDraw3D.draw_arrow(position + transform.basis.y * 2, 
	position + transform.basis.y * 2 + target_rotation.basis.z*-last_drag*0.5,
	Color.BLUE, 0.1)



func _physics_process(delta):
	last_delta = delta
	if(Input.is_action_just_pressed("attack_light")):
		target_rotation.rotation = Vector3.UP
		vel = 0
	
	var forwards = vel > 0	
	
	var r = raycast_secondary if forwards else raycast_secondary_2
	if(!r.is_colliding()):
		r = raycast_secondary_2 if forwards else raycast_secondary
		if(!r.is_colliding()):
			r = raycast
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	vel *= 0.99
	vel -= input_dir.y * 30 * delta
	last_friction = target_rotation.transform.basis.z.y * 10 * delta
	vel += -last_friction
	last_drag = 1 - ((vel*vel) * delta * 0.0001)
	vel *= 1 - ((vel*vel) * delta * 0.0001)
	if(r.get_collider() != null && abs(r.get_collision_normal().dot(target_rotation.transform.basis.y)) > 0.1):
		angle -= input_dir.x * delta * vel * 0.5 * (1.0 - (vel/50))
		target_rotation.rotation = Quaternion(Vector3.UP, r.get_collision_normal()).get_euler()
		target_rotation.rotate_object_local(Vector3.UP, angle)
	elif(r.get_collider() != null && (r == raycast_secondary || r == raycast_secondary_2)):
		#vel -= 1
		#target_rotation.rotation = Quaternion(Vector3.UP, r.get_collision_normal()).get_euler()
		#target_rotation.rotate_object_local(Vector3.UP, angle)
		#vel = 0
		pass
	else:
		$MeshInstance3D.rotate_object_local(Vector3.UP, -input_dir.x * 5 * delta)
		target_rotation.rotation = $MeshInstance3D.rotation
	
	#target_rotation.rotation = Quaternion(Vector3.UP, r.get_collision_normal()).get_euler()
	#target_rotation.rotate_object_local(Vector3.UP, angle)
		
	#$"MeshInstance3D".rotation = Quaternion(Vector3.UP, raycast.get_collision_normal()).get_euler()
	#$"MeshInstance3D".rotate_object_local(Vector3.UP, angle)
	
	velocity.y -= 16 * delta
	velocity *= 0.998
	if(raycast.get_collider() != null):
		if (target_rotation.transform.basis.z * vel + Vector3(0,-1,0)).normalized().dot(velocity.normalized()) < 0:
			vel *= -1
		velocity = target_rotation.transform.basis.z * vel
		velocity.y -= 1
		
		if(Input.is_action_just_released("roll")):
			position.y += 0.1
			velocity.y = 10
			
	else:
		vel *= 0.998
	move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if(abs(collision.get_normal().dot(target_rotation.transform.basis.y)) > 0.8 && r.get_collision_point() != collision.get_position()):
			target_rotation.rotation = Quaternion(Vector3.UP, collision.get_normal()).get_euler()
			target_rotation.rotate_object_local(Vector3.UP, angle)
		
	if(r.get_collider() != null):
		$"MeshInstance3D".rotation = Quaternion.from_euler($"MeshInstance3D".rotation).slerp(Quaternion.from_euler(target_rotation.rotation), delta*10).get_euler()
	
