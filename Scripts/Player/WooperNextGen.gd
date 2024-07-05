extends Node3D
class_name Wooper

@onready var BACKWARDS : Node3D = $Backwards

@export_subgroup("Special Properties")
@export var SLOW_MOTION = 0.1
@export var SPEED_CAP = 15
@export var CRASH_VELOCITY = 20

@export_subgroup("Debug Properties")
@export var DEBUG_ARROW_THICKNESS = 0.05
@export var DEBUG_WALLPLANTS = false
@export var DEBUG_VERT = false
@export var DEBUG_GRIND = false
@export var DEBUG_NORMAL = true
@export var DEBUG_DIRECTION = true

@export_subgroup("Grounded Properties")
@export var GRAVITY = 9.8
@export var FRICTION = 0.5
@export var HORIZONTAL_DRAG = 0.99
@export var DRAG = 0.99
@export var MINIMUM_SPEED = 5
@export var JUMP_ALWAYS_HOLD = false
@export var JUMP_FORCE = 4
@export var JUMP_VERT_FORCE = 2
@export var JUMP_TIMER = 0.1
@export var JUMP_MINIMUM_FACTOR = 0.5
@export var JUMP_HOLD_FRICTION = 0.2 #Friction before an Ollie
@export var JUMP_HOLD_DRAG = 0.99 #Friction before an Ollie
@export var JUMP_HOLD_SPEED = 0.5
@export var DRIFT_FORCE = 5
@export var DRIFT_FORCE_DRAG = 0.99
@export var TURN_MULTIPLIER = 0.1
@export var GROUND_OFFSET = 0.05
@export var UP_SLOPE_ACCELERATION = 10
@export var DOWN_SLOPE_ACCELERATION = 30
@export var UP_VERT_SLOPE_ACCELERATION = 10
@export var DOWN_VERT_SLOPE_ACCELERATION = 30
@export var KICK_FORCE = 10

@export_subgroup("Airborne Properties")
@export var AIR_TURN_SPEED = 5
@export var WALLPLANT_DECAY_MULTIPLIER = 5
@export var AIR_TO_GROUND_MOMENTUM_LOSS = 0.75
@export var AIR_TO_GROUND_SIDE_MOMENTUM_LOSS = 0.25
@export var VERT_MAGNETISM = 1

@export_subgroup("Rail Properties")
@export var GRIND_FRICTION = 0
@export var GRIND_DRAG = 0.995
@export var GRIND_MAGNETISM = 1.5
@export var UP_GRIND_SLOPE_ACCELERATION = 5
@export var DOWN_GRIND_SLOPE_ACCELERATION = 40
@export var MINIMUM_GRIND_SPEED = 0.1

@export_subgroup("Balance Properties")
@export var BALANCE_MIN_DIFFICULTY = 0.2
@export var BALANCE_START_RANGE = 0.2
@export var BALANCE_MULT_DIFFICULTY = 1
@export var BALANCE_MULT_INPUT = 10
@export var BALANCE_MANUAL_MIN_DIFFICULTY = 0.2
@export var BALANCE_MANUAL_START_RANGE = 0.2
@export var BALANCE_MANUAL_MULT_DIFFICULTY = 1
@export var BALANCE_MANUAL_MULT_INPUT = 10
@export var BALANCE_MANUAL_TURN_SPEED = 3
@export var BALANCE_MANUAL_DIFF_INCREASE = 0.25

@export_subgroup("Visual Properties")
@export var LERP_SPEED = 20
@export var BAIL_DRAG = 0.95
@export var STICKER : PackedScene
@export var CLONE_WOOPER : Node3D;

@export_subgroup("Multiplayer Properties")
@export var MP_INTERPOLATION_SPEED = 3
@export var MP_COLLISIONS_ENABLED = false

@onready var _multiplayer_manager = get_node("/root/MultiplayerManager")
@onready var horizontal_balance = $Balance/HORIZONTAL_BALANCE
@onready var vertical_balance = $Balance/VERTICAL_BALANCE
@onready var score_label = $Balance/SCORE_LABEL
@onready var final_score_label = $Balance/FINAL_SCORE_LABEL
@onready var move_label = $Balance/MOVE_LABEL
@onready var balance_animation = $Balance/AnimationPlayer
@onready var area = $Area3D

func _ready():
	GameManager.player = self
	pass

var physics_framerate = 0

enum STATE {
	grounded,
	airborne,
	railed, 
	vert,
	transition
}

var friction = FRICTION
var drag = DRAG

var state = STATE.grounded
var to_state = STATE.transition
var to_position = Vector3.ZERO
var to_rotation = Quaternion.IDENTITY
var velocity = Vector3(0,0,0)
var angle = 0

var score = 0
var multiplier = 0
var move_list = []

var preparing_vert = false

func _process(delta):
	if(GameManager.paused):
		return
	DebugDraw2D.set_text("physics_framerate", physics_framerate)
	DebugDraw2D.set_text("vert_ground", vert_ground)
	DebugDraw2D.set_text("gravity_raycast", $GravityRay.is_colliding(), 0, Color.RED if $GravityRay.is_colliding() else Color.WHITE)
	var input = Input.get_axis("down", "up")
	DebugDraw2D.set_text("input", input,0,Color.GREEN if input >= 0 else Color.RED )
	DebugDraw2D.set_text("state", state,1)
	DebugDraw2D.set_text("speed", velocity.length(),1)
	DebugDraw2D.set_text("forward_speed", velocity.z,1)
	DebugDraw2D.set_text("last_angle",prev_ground_angle)
	DebugDraw2D.set_text("angle",angle)
	if(DEBUG_VERT):
		DebugDraw2D.set_text("vert", preparing_vert,1,Color.WHITE if !preparing_vert else Color.RED)
		DebugDraw2D.set_text("vert_coords", vert_coords,2,Color.WHITE)
		DebugDraw2D.set_text("vert_dir", vert_dir,2,Color.WHITE)
	if(DEBUG_WALLPLANTS):
		DebugDraw2D.set_text("wallplant", wallplant_speed,1)
	if(DEBUG_DIRECTION):
		DebugDraw3D.draw_arrow(position, position + local_to_global_vector(velocity),Color.WHITE, DEBUG_ARROW_THICKNESS)
		DebugDraw3D.draw_arrow(position, position + Vector3(0,-5,0),Color.RED, DEBUG_ARROW_THICKNESS)
		DebugDraw2D.set_text("velocity",velocity)

	if(CLONE_WOOPER != null):
		CLONE_WOOPER.rotation = Quaternion.from_euler(CLONE_WOOPER.rotation).slerp(Quaternion.from_euler($MeshInstance3D.global_rotation), min(delta * (LERP_SPEED),1)).get_euler()
		CLONE_WOOPER.position = position
	
	if(score > 0):
		score_label.text = str(round(score)*100) + " x " + str(multiplier)
	else:
		score_label.text = ""
	move_label.text = ""
	for i in range(5):
		if(i < move_list.size()):
			if(i > 0):
				move_label.text += " + "
			move_label.text += move_list[i]
	if(move_list.size() > 5):
		move_label.text += " + ..."
			

func _physics_process(delta):
	angle = normalize_angle(angle)
	physics_framerate = 1/delta
	if(Input.is_action_just_pressed("debug_menu")):
		Engine.time_scale = 1
		GameManager.toggle_menu()
	if(GameManager.paused):
		return
	wallplant_speed *= 1 - min(delta * WALLPLANT_DECAY_MULTIPLIER,1)
	if(Input.is_action_just_pressed("reset")):
		GameManager.reload()
	if(Input.is_action_pressed("slow")):
		Engine.time_scale = SLOW_MOTION
	else:
		Engine.time_scale = 1
	
	vertical_balance.hide()
	horizontal_balance.hide()
	if(has_jumped):
		jump_timer += delta
	if(state == STATE.airborne):
		airborne_physics(delta)
	elif(state == STATE.grounded):
		ground_physics(delta)
	elif(state == STATE.railed):
		rail_physics(delta)
	elif(state == STATE.vert):
		vert_physics(delta)
	elif(state == STATE.transition):
		position = position.lerp(to_position,delta * 2)
		rotation = Quaternion.from_euler(rotation).slerp(to_rotation, delta * 2).get_euler()

func start_animation(anim):
	if(!CLONE_WOOPER.ANIMATION_TREE["parameters/" + anim + "/active"]):
		if(_multiplayer_manager):
			_multiplayer_manager.updatePlayerAnimation.rpc("parameters/" + anim + "/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	CLONE_WOOPER.ANIMATION_TREE.set("parameters/" + anim + "/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
func stop_animation(anim):
	if(CLONE_WOOPER.ANIMATION_TREE["parameters/" + anim + "/active"]):
		if(_multiplayer_manager):
			_multiplayer_manager.updatePlayerAnimation.rpc("parameters/" + anim + "/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	CLONE_WOOPER.ANIMATION_TREE.set("parameters/" + anim + "/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
		
func set_animation(anim,value):
	if(CLONE_WOOPER.ANIMATION_TREE["parameters/" + anim + "/blend_amount"] != value):
		if(_multiplayer_manager):
			_multiplayer_manager.updatePlayerAnimation.rpc("parameters/" + anim + "/blend_amount", value)
	CLONE_WOOPER.ANIMATION_TREE.set("parameters/" + anim + "/blend_amount", value)
	
func set_transition(anim,value):
	if(CLONE_WOOPER.ANIMATION_TREE["parameters/" + anim + "/transition_request"] != value):
		if(_multiplayer_manager):
			_multiplayer_manager.updatePlayerAnimation.rpc("parameters/" + anim + "/transition_request", value)
	CLONE_WOOPER.ANIMATION_TREE.set("parameters/" + anim + "/transition_request", value)
	
func trick_animation():
	if(Input.is_action_pressed("down")):
		set_transition("Flip", "shuvit")
		start_animation("Kickflip")
		multiplier+=1
		score += 40
		move_list.push_front("Pop Shuvit")
	elif(Input.is_action_pressed("left")):
		set_transition("Flip", "kickflip")
		start_animation("Kickflip")
		move_list.push_front("Kickflip")
		score += 30
		multiplier+=1
	elif(Input.is_action_pressed("right")):
		set_transition("Flip", "heelflip")
		start_animation("Kickflip")
		move_list.push_front("Heelflip")
		score += 30
		multiplier+=1
	elif(Input.is_action_pressed("up")):
		set_transition("Flip", "impossible")
		start_animation("Kickflip")
		move_list.push_front("Impossible")
		score += 50
		multiplier+=1

func clear_score():
	score = 0
	multiplier = 0

func end_combo():
	if(score != 0):
		var f_score = int(round(score)*100 * multiplier)
		var text = ""
		while f_score >= 1000:
			text += ",%03d" % (f_score % 1000)
			f_score /= 1000
		final_score_label.text = str(f_score) + text
		score = 0
		multiplier = 0
		move_list = []
		balance_animation.play("Sucess")
	
func fail_combo():
	move_list = []
	balance_animation.play("Fail")

#Resets and bails the player
func reset():
	fail_combo()
	manual = false
	set_animation("Manual", 0)
	rotation = Vector3.ZERO
	rotate_object_local(Vector3.UP, angle)
	start_animation("Bail")
	$GravityRay.force_raycast_update()
	$ResetRay.force_raycast_update()
	force_snap_to_ground()
	
	
#Resets and crashes the player
func crash():
	fail_combo()
	set_animation("Manual", 0)
	rotation = Vector3.ZERO
	rotate_object_local(Vector3.UP, angle)
	start_animation("Crash")
	$GravityRay.force_raycast_update()
	$ResetRay.force_raycast_update()
	force_snap_to_ground()

			
func jump():
	var jump_factor = JUMP_MINIMUM_FACTOR + CLONE_WOOPER.ANIMATION_TREE["parameters/Prepare/blend_amount"] * (1 - JUMP_MINIMUM_FACTOR)
	start_animation("OneShot")
	InputBuffer._invalidate_action("jump")
	if(preparing_vert):
		var vel_base = velocity + (basis.inverse().y * JUMP_VERT_FORCE * jump_factor)
		var vel_mod = velocity + global_to_local_vector(Vector3(0,JUMP_FORCE * jump_factor,0))
		var ratio = basis.y.dot(Vector3(0,1,0))
		print(ratio)
		velocity = vel_base * (1.0-ratio) + vel_mod * ratio
		if(check_vert()):
			set_animation("Manual", 0)
			$AudioStreamPlayer3D.play()
			has_jumped = true
			return
	else:
		velocity.y += JUMP_FORCE * jump_factor
	jump_timer = JUMP_TIMER - (jump_factor * JUMP_TIMER)
	#preparing_vert = false
	CLONE_WOOPER.ANIMATION_TREE["parameters/Prepare/blend_amount"] = 0
	state = STATE.airborne
	set_animation("Manual", 0)
	airborne_angle = 0
	has_jumped = true
	$AudioStreamPlayer3D.play()

func cap_velocity():
	if(velocity.length() > SPEED_CAP):
		velocity = velocity.normalized() * SPEED_CAP
	
func global_to_local_vector(vec):
	return basis.inverse() * vec

func local_to_global_vector(vec):
	return basis * vec

#GROUNDING CODE

var prev_ground_angle = 0	

#BLAME CHAT-GPT
func normalize_angle(angle):
	while angle <= -PI:
		angle += 2 * PI
	while angle > PI:
		angle -= 2 * PI
	return angle

func angle_difference(angle1, angle2):
	var diff = normalize_angle(angle1) - normalize_angle(angle2)
	return normalize_angle(diff)

func snap_to_ground():
	check_airborne()
	preparing_vert = false
	if(state == STATE.grounded):
		var point = $GravityRay.get_collision_point()
		var layer = $GravityRay.get_collider().get_collision_layer()
		var ground_angle = atan2($GravityRay.get_collision_normal().z, $GravityRay.get_collision_normal().x)
		if(layer == 5 || layer == 4):
			preparing_vert = true
		position = point + basis.y * GROUND_OFFSET
		rotation = Quaternion(Vector3.UP, $GravityRay.get_collision_normal()).get_euler()
		var off_angle = angle_difference(prev_ground_angle, ground_angle )
		angle -= (1 - abs(basis.y.y)) * off_angle
		rotate_object_local(Vector3.UP, angle)
		prev_ground_angle = ground_angle
		
func force_snap_to_ground():
	force_check_airborne()
	if(state == STATE.grounded):
		var point = $ResetRay.get_collision_point()
		position = point + basis.y * GROUND_OFFSET
		rotation = Quaternion(Vector3.UP, $ResetRay.get_collision_normal()).get_euler()
		rotate_object_local(Vector3.UP, angle)
		
func check_walls():
	var checks = $WallCheck.get_children()
	var movement = Vector3.ZERO
	var pushback = Vector3.ZERO
	$WallCheck/Forward.force_raycast_update()
	if($WallCheck/Forward.is_colliding() && velocity.length() > CRASH_VELOCITY):
		var point = $WallCheck/Forward.get_collision_point()
		var distance = abs($WallCheck/Forward.target_position.y) - $WallCheck/Forward.global_position.distance_to(point)
		global_position += $WallCheck/Forward.global_transform.basis.y * distance * 1.1
		velocity = Vector3.ZERO
		crash()
		return
	var count = 0
	for c in checks:
		c.force_raycast_update()
		if(c.is_colliding()):
			if(c.get_collision_normal().dot(Vector3.UP) >= 0.9):
				reset()
				return
			count += 1
			var point = c.get_collision_point()
			var distance = abs(c.target_position.y) - c.global_position.distance_to(point)
			movement += c.global_transform.basis.y * distance * 1.1
			pushback += global_to_local_vector(c.get_collision_normal())
	global_position = global_position + movement
	if(count > 0):
		velocity += pushback/count
		
		

var jump_timer = 0
var has_jumped = false
var vert_ground = false

var manual = false

func ground_physics(delta):
	wallplant_speed = Vector3.ZERO
	if(CLONE_WOOPER.ANIMATION_TREE["parameters/Bail/active"] || CLONE_WOOPER.ANIMATION_TREE["parameters/Crash/active"]):
		velocity *= BAIL_DRAG
		velocity.y -= GRAVITY * delta
		snap_to_ground()
		check_walls()
		position += basis.z * velocity.z * delta
		position += basis.y * velocity.y * delta
		position += basis.x * velocity.x * delta
		return
	var manual_type = "base"
	var manual1 = InputBuffer.is_combo_pressed(["up","down"]) 
	var manual2 = InputBuffer.is_combo_pressed(["down","up"]) 
	if((manual1 || manual2) && !manual):
		balance = randf_range(-BALANCE_MANUAL_START_RANGE,BALANCE_MANUAL_START_RANGE)
		if(balance == 0):
			balance = 0.1
		balance_diff = BALANCE_MANUAL_MIN_DIFFICULTY
		bal_speed = 0
		manual = true
		set_animation("Manual", 1)
		if(manual2):
			if(velocity.z < 0):
				manual_type = "special"
		if(manual1):
			if(velocity.z > 0):
				manual_type = "special"
		if(manual_type == "base"):
			move_list.push_front("Manual")
		else:
			move_list.push_front("Nose Manual")
		set_transition("ManualType", manual_type)
		multiplier += 1
		score += 20
	if(manual):
		if(InputBuffer.is_combo_pressed(["grind", "trick"])):
			set_transition("ManualType", "pogo")
			move_list.push_front("Pogo")
			multiplier += 1
			score += 10
		if(InputBuffer.is_combo_pressed(["trick", "grind"])):
			set_transition("ManualType", "spin")
			move_list.push_front("Manual Spin")
			multiplier += 1
			score += 10
		if(InputBuffer.is_combo_pressed(["trick", "trick"])):
			set_transition("ManualType", "special")
			move_list.push_front("Nose Manual")
			multiplier += 1
			score += 10
		if(InputBuffer.is_combo_pressed(["grind", "grind"])):
			set_transition("ManualType", "base")
			move_list.push_front("Manual")
			multiplier += 1
			score += 10
		score += delta
		vertical_balance.show()
		balance_diff += delta * BALANCE_MANUAL_DIFF_INCREASE
		bal_speed += (balance * (BALANCE_MANUAL_MULT_DIFFICULTY + balance_diff)) * delta
		bal_speed += Input.get_axis("down","up") * BALANCE_MANUAL_MULT_INPUT * delta
		balance += bal_speed * delta
		vertical_balance.value = (balance * 50) + 50
		if(abs(balance) > 1):
			manual = false
			vertical_balance.hide()
			set_animation("Manual", 0)
			reset()
			
	else:
		end_combo()
	CLONE_WOOPER.ANIMATION_TREE.set("parameters/Kickflip/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	CLONE_WOOPER.ANIMATION_TREE.set("parameters/Falling/blend_amount", 0)
	snap_to_ground()
	check_walls()
	
	var input_dir = Input.get_vector("left", "right", "down", "up")
	var pow = Input.get_action_strength("drift")
	var drift = pow * pow * DRIFT_FORCE + 1 if Input.is_action_pressed("drift") else 1
	if Input.is_action_pressed("drift"):
		velocity.z *= DRIFT_FORCE_DRAG
	angle -= input_dir.x * drift * delta
	if(manual):
		angle -= input_dir.x * delta * BALANCE_MANUAL_TURN_SPEED

	$MeshInstance3D.rotation = Vector3.ZERO
	CLONE_WOOPER.ANIMATION_TREE["parameters/Direction/blend_amount"] = (Input.get_axis("left", "right") * (Input.get_action_strength("drift")+1)/2)
	
	if(!Input.is_action_pressed("jump") && !manual):
		velocity.z += (1-Input.get_action_strength("down")) * MINIMUM_SPEED * delta
	if(Input.is_action_just_pressed("kick") && !manual && !CLONE_WOOPER.ANIMATION_TREE["parameters/Kick/active"]):
		velocity.z += max(KICK_FORCE - velocity.z,0)
		start_animation("Kick")
	
	#GRAVTIY	
	velocity.y = -1

	#Slope speedup
	var mult = 0
	vert_ground = false
	if($GravityRay.get_collider()):
		var layer = $GravityRay.get_collider().get_collision_layer()
		vert_ground = layer == 5 || layer == 4
	if(sign(basis.z.y) == 1):
		if(!vert_ground):
			mult = -basis.z.y * UP_SLOPE_ACCELERATION
		else:
			mult = -basis.z.y * UP_VERT_SLOPE_ACCELERATION
			
		
	elif(sign(basis.z.y) == -1):
		if(!vert_ground):
			mult = -basis.z.y * DOWN_SLOPE_ACCELERATION
		else:
			mult = -basis.z.y * DOWN_VERT_SLOPE_ACCELERATION
		
	if(velocity.z < 0):
		velocity.z += mult * delta 
	else:
		velocity.z += mult * delta 
		
	velocity -= (velocity * friction) * delta
	velocity.x *= HORIZONTAL_DRAG
	
	#velocity -= sign(velocity) * (velocity * velocity) * 0.0001
	if(Input.is_action_just_released("jump")):
		jump()
	elif(Input.is_action_pressed("jump")):
		CLONE_WOOPER.ANIMATION_TREE.set("parameters/Prepare/blend_amount", lerp(CLONE_WOOPER.ANIMATION_TREE["parameters/Prepare/blend_amount"] + 0.0,1.0,min(1,delta*JUMP_HOLD_SPEED)))
		drag = JUMP_HOLD_DRAG
		velocity *= drag
		friction = JUMP_HOLD_FRICTION
	elif(manual || JUMP_ALWAYS_HOLD):
		drag = JUMP_HOLD_DRAG
		velocity *= drag
		friction = JUMP_HOLD_FRICTION
	else:
		CLONE_WOOPER.ANIMATION_TREE.set("parameters/Prepare/blend_amount", 0)
		drag = DRAG
		velocity *= drag
		friction = FRICTION
	
	cap_velocity()
	
	position += basis.z * velocity.z * delta
	position += basis.y * velocity.y * delta
	position += basis.x * velocity.x * delta
	
	if(InputBuffer.is_action_press_buffered("grind")&& !Input.is_action_pressed("jump")):
		check_rail()
		
	if(state == STATE.vert):
		return

#AIRBORNE STATE
#INCLUDES STUFF FOR WHEN THE PLAYER IS IN THE AIR

var wallplant_speed = Vector3.ZERO

func check_airborne():
	
	if(has_jumped && jump_timer > JUMP_TIMER):
		has_jumped = false
		jump_timer = 0
	state = STATE.airborne if !$GravityRay.is_colliding() else STATE.grounded
	if(has_jumped):
		state = STATE.airborne
		
	if(preparing_vert && $GravityRay.is_colliding()):
		var layer = $GravityRay.get_collider().get_collision_layer()
		if(layer != 5 && layer != 4):
			if(check_vert()):
				set_animation("Manual", 0)
			
	if(state == STATE.airborne && preparing_vert):
		if(check_vert()):
			set_animation("Manual", 0)
			return false
	return state == STATE.airborne
	
func force_check_airborne():
	state = STATE.airborne if !$ResetRay.is_colliding() else STATE.grounded
	return state == STATE.airborne
	
func check_airborne_in_air():
	if(has_jumped && jump_timer > JUMP_TIMER):
		has_jumped = false
		jump_timer = 0
	state = STATE.airborne if !$GravityRay.is_colliding() else STATE.grounded
	if(has_jumped):
		state = STATE.airborne
	return state == STATE.airborne

func check_walls_airborne(_delta):
	var movement = Vector3.ZERO
	var pushback = Vector3.ZERO
	var checks = $WallCheck.get_children()
	checks.push_back($Up)
	for c in checks:
		if(c.is_colliding()):
			var point = c.get_collision_point()
			var distance = abs(c.target_position.y) - c.global_position.distance_to(point)
			movement += (c.global_transform.basis.y * distance * 1.1)
			pushback += global_to_local_vector(c.get_collision_normal())
	global_position = global_position + movement
	velocity += pushback

var airborne_angle = 0

func airborne_physics(delta):
	if(CLONE_WOOPER.ANIMATION_TREE["parameters/Bail/active"] || CLONE_WOOPER.ANIMATION_TREE["parameters/Crash/active"]):
		velocity -= global_to_local_vector(Vector3(0,GRAVITY,0)) * delta
		velocity *= BAIL_DRAG
		snap_to_ground()
		check_walls()
		position += basis.z * velocity.z * delta
		position += basis.y * velocity.y * delta
		position += basis.x * velocity.x * delta
		return
	manual = false
	set_animation("Manual", 0)
	if(velocity.length() > wallplant_speed.length()):
		wallplant_speed = velocity
		
	if(CLONE_WOOPER.ANIMATION_TREE["parameters/Wallplant/active"]):
		return;
	airborne_angle += Input.get_axis("down", "up") * delta
	
	
	
	var temp_velocity = local_to_global_vector(velocity)
	var target = Quaternion.from_euler(Vector3(0,angle,0))
	if(get_world_3d() != null):
		var s_s = get_world_3d().direct_space_state
		var q = PhysicsRayQueryParameters3D.create(position, position + Vector3(0,-1000, 0))
		var r = s_s.intersect_ray(q)
		if(r.size() != 0):
			#target = Quaternion(Vector3.UP, r["normal"])
			var trans = Transform3D(Quaternion(Vector3.UP, r["normal"]))
			trans = trans.rotated_local(Vector3.UP, angle)
			#target = new_transform.basis * target
			#target.x = rotation.x
			if(DEBUG_DIRECTION):
				DebugDraw3D.draw_arrow(global_position,global_position + trans.basis.x,Color.GREEN, DEBUG_ARROW_THICKNESS)
				DebugDraw3D.draw_arrow(global_position,global_position + trans.basis.y,Color.BLUE, DEBUG_ARROW_THICKNESS)
				DebugDraw3D.draw_arrow(global_position,global_position + trans.basis.z,Color.RED, DEBUG_ARROW_THICKNESS)
			
			basis = basis.orthonormalized().slerp(trans.basis.orthonormalized(),min(1,delta * max(4,(SPEED_CAP - velocity.length())/SPEED_CAP*4)))
		else:
			rotation = rotation.slerp(target.get_euler(), delta)
	else:
		rotation = rotation.slerp(target.get_euler(), delta)
	velocity = global_to_local_vector(temp_velocity)

	CLONE_WOOPER.ANIMATION_TREE.set("parameters/Falling/blend_amount", 1)
	check_walls_airborne(delta)
	var input_dir = Input.get_vector("left", "right", "down", "up")
	var prev_angle = angle
	angle -= input_dir.x * AIR_TURN_SPEED * delta
	var global_velocity = local_to_global_vector(velocity)
	rotate_object_local(Vector3.UP, angle - prev_angle)
	velocity = global_to_local_vector(global_velocity)
	
	velocity -= global_to_local_vector(Vector3(0,GRAVITY,0)) * delta
	
	velocity *= 0.998
	
	
	cap_velocity()
	
	position += basis.z * velocity.z * delta
	position += basis.y * velocity.y * delta
	position += basis.x * velocity.x * delta
	
	
	
	if(!check_airborne_in_air()):
		var vel_global = local_to_global_vector(velocity)
		global_rotation = $MeshInstance3D.global_rotation
		$MeshInstance3D.rotation = Vector3.ZERO
		var v = basis.z
		v.y = 0
		v.normalized()
		angle = atan2(v.x,v.z)
		snap_to_ground()
		velocity = global_to_local_vector(vel_global)
		velocity.x *= AIR_TO_GROUND_SIDE_MOMENTUM_LOSS
		velocity.z += sign(velocity.z) * abs(velocity.y) * (1 - AIR_TO_GROUND_MOMENTUM_LOSS)
		velocity.y = 0
		start_animation("Floor")
		$DropAudio.play()
		if(CLONE_WOOPER.ANIMATION_TREE["parameters/Kickflip/active"]):
			reset()
		
	if(InputBuffer.is_action_press_buffered("grind") ):
		check_rail()
	if(InputBuffer.is_action_press_buffered("jump") && wallplant_speed.length() > 1):
		$SlapRay.force_raycast_update()
		if($SlapRay.is_colliding()):
			var vel_global = global_to_local_vector(wallplant_speed)
			var vel_normal = -(Vector3(vel_global.x,0,vel_global.z)).normalized()
			var normal = $SlapRay.get_collision_normal()
			var normal_angled = Vector3(normal.x,0,normal.z)
			var point = $SlapRay.get_collision_point()
			if(abs(normal.y) < 0.04 && abs(vel_normal.dot(normal)) > 0):
				var new_angle = atan2(normal.x, normal.z)
				rotate_object_local(Vector3.UP, new_angle - angle)
				angle = new_angle
				wallplant_speed.x = 0
				velocity = (global_to_local_vector(normal)) * wallplant_speed.length()
				velocity.y += 2
				velocity.z *= 1.5
				global_position = point
				global_position += normal * 0.2
				if(DEBUG_WALLPLANTS):
					DebugDraw3D.draw_arrow(point, 
					point + normal,Color.RED,DEBUG_ARROW_THICKNESS,false, 5)
					DebugDraw3D.draw_arrow(point, 
					point + (global_to_local_vector(velocity)).normalized(),Color.BLUE,DEBUG_ARROW_THICKNESS,false, 5)
				if(STICKER != null):
					var obj = STICKER.instantiate()
					get_parent().add_child(obj)
					obj.global_position = global_position
					obj.global_rotation = global_rotation
					start_animation("Wallplant")
					score += 40
					multiplier += 1
					move_list.push_front("Wallplant")
				CLONE_WOOPER.rotation = rotation
				
				return
	if(Input.is_action_pressed("drift") && !spine_lock):
		var space_state = get_world_3d().direct_space_state
		var forward = basis.z
		forward.y = 0
		forward = forward.normalized()
		var scale = 1
		var query = PhysicsRayQueryParameters3D.create(position + forward * scale, (position + forward * scale) +  Vector3(0,-100, 0))
		var result = space_state.intersect_ray(query)
		if(result.size() != 0):
			if(DEBUG_VERT):
				DebugDraw3D.draw_arrow(position + forward * scale, result["position"],Color.GREEN, DEBUG_ARROW_THICKNESS,false, 100)

			var layer = result["collider"].get_collision_layer()
			if(result["normal"].y > 0 && (layer == 4 || layer == 5)):
				var normal_angle = result["normal"]
				normal_angle.y = 0
				normal_angle = normal_angle.normalized()
				var velocity_angle = local_to_global_vector(velocity)
				velocity_angle.y = 0
				velocity_angle = velocity_angle.normalized()
				if(velocity_angle.dot(normal_angle) > 0):
					check_vert_relative(result["position"])
		return
	if(InputBuffer.is_action_press_buffered("trick") && !CLONE_WOOPER.ANIMATION_TREE["parameters/Kickflip/active"]):
		trick_animation()


#RAIL STATE
#THE STATE FOR GRINDING ON RAILS

var rail = null
var offset = 0
var rail_backwards = false

func check_rail():
	GameManager._rails.sort_custom(
		func(a, b):
			return a.get_distance(global_position) < b.get_distance(global_position)
			)
	for r in GameManager._rails:
		if(r == null):
			continue
		if(velocity.z < MINIMUM_GRIND_SPEED && r.fall_on_low_speed):
			continue
		if(r.get_distance(global_position) < GRIND_MAGNETISM):
			var trans = r.get_angle(global_position)
			if(trans != null):
				if(abs(trans.basis.z.dot(basis.z)) < 0.5):
					continue
			else:
				continue
			
			if(CLONE_WOOPER.ANIMATION_TREE["parameters/Kickflip/active"]):
				stop_animation("Kickflip")
				reset()
				return
			
			state = STATE.railed
			rail = r
			offset = r.get_offset(global_position)
			var d = rail.get_angle(global_position).basis.z.dot(basis.z)
			if d < 0:
				velocity.z *= -1
			
			#balance = randf_range(-0.2,0.2)
			#if(balance == 0):
				#balance = 0.1
			#balance_diff = 0.2
			#bal_speed = 0
			set_transition("GrindTricks", "base")
			balance = randf_range(-BALANCE_START_RANGE,BALANCE_START_RANGE)
			if(balance == 0):
				balance = 0.1
			balance_diff = BALANCE_MIN_DIFFICULTY
			bal_speed = 0
			
			move_list.push_front("Grind")
			score += 20
			multiplier += 1
			
			$RailAudio.play()
			return
	
func drop_rail():
	$RailAudio.stop()
	var v = basis.z
	v.y = 0
	v.normalized()
	angle = atan2(v.x,v.z)
	if(velocity.z < 0):
		velocity.z *= -1
	velocity.x = -Input.get_axis("left","right") * (velocity.z * 0.5)
	velocity.z *= 1-abs(Input.get_axis("left","right")) * 0.5
	
	set_animation("Grinding", 0)
	
	airborne_angle = 0
	state = STATE.airborne
	
var balance = 0.1
var balance_diff = 0.2
var bal_speed = 0
	
func rail_physics(delta):	
	score += delta * 2
	manual = false
	horizontal_balance.show()
	balance_diff += delta
	bal_speed += (balance * (BALANCE_MULT_DIFFICULTY + balance_diff)) * delta
	bal_speed += Input.get_axis("left","right") * BALANCE_MULT_INPUT * delta
	balance += bal_speed * delta
	horizontal_balance.value = (balance * 50) + 50
	if(abs(balance) > 1):
		drop_rail()
		return
	if(InputBuffer.is_combo_pressed(["grind","grind"])):
		move_list.push_front("Straight Grind")
		score += 20
		multiplier += 1
		set_transition("GrindTricks", "manual")
	if(InputBuffer.is_combo_pressed(["grind","trick"])):
		move_list.push_front("Other Grind")
		score += 20
		multiplier += 1
		set_transition("GrindTricks", "manual2")
	if(InputBuffer.is_combo_pressed(["trick","trick"])):
		move_list.push_front("Wierd Grind")
		score += 20
		multiplier += 1
		set_transition("GrindTricks", "manual3")
	if(InputBuffer.is_combo_pressed(["trick","grind"])):
		move_list.push_front("Grind")
		score += 20
		multiplier += 1
		set_transition("GrindTricks", "base")
	
	set_animation("Grinding",1)
	CLONE_WOOPER.ANIMATION_TREE.set("parameters/Kickflip/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	velocity.y = 0
	$MeshInstance3D.global_rotation = global_rotation
	if(rail == null):
		reset()
		return
	offset -= delta * velocity.z
	if(velocity.z < MINIMUM_GRIND_SPEED && rail.fall_on_low_speed):
		drop_rail()
		return
	var pos = rail.get_closest_point_offset(offset)
	var trans = rail.get_angle_offset(offset)
	if(pos == null || trans == null):
		drop_rail()
		return
	position = pos
	transform = trans
	
	var mult = 0
	if(sign(trans.basis.z.y) == 1):
		mult = -trans.basis.z.y * DOWN_GRIND_SLOPE_ACCELERATION
	elif(sign(basis.z.y) == -1):
		mult = -trans.basis.z.y * UP_GRIND_SLOPE_ACCELERATION
		
	if(velocity.z < 0):
		velocity.z += mult * delta 
	else:
		velocity.z += mult * delta 
	velocity.z += sign(velocity.z) * rail.speedup * delta
	
	if(velocity.z < 0):
		rotate_object_local(Vector3.UP, PI)
	
	velocity -= (velocity * GRIND_FRICTION) * delta
	velocity *= GRIND_DRAG
	
	
	if(Input.is_action_just_pressed("drift")):
		drop_rail()
		return
	
	if(Input.is_action_just_released("jump")):
		drop_rail()
		jump()
	elif(InputBuffer.is_action_press_buffered("jump")):
		CLONE_WOOPER.ANIMATION_TREE.set("parameters/Prepare/blend_amount", lerp(CLONE_WOOPER.ANIMATION_TREE["parameters/Prepare/blend_amount"] + 0.0,1.0,min(delta*JUMP_HOLD_SPEED,1)))
	else:
		CLONE_WOOPER.ANIMATION_TREE.set("parameters/Prepare/blend_amount", 0)
	pass
	

#VERT CODE
#ENTERED WHEN PASSING BY A VERT TRIGGER

var vert = null
var vert_coords = Vector2(0,0)
var vert_dir = Vector3(0,0,0)
var vert_vel = Vector2(0,0)
var vert_angle_offset = 0

var vert_timer = 0
var vert_side = 0 #0 - Right \ 1 - Left	

	
func check_vert_state():
	state = STATE.vert
	if($GravityRay.is_colliding()):
		var layer = $GravityRay.get_collider().get_collision_layer()
		if(layer == 5 || layer == 4):
			state = STATE.grounded
	return state == STATE.vert

func snap_to_ground_vert():
	check_vert_state()
	if(state == STATE.grounded):
		velocity = global_to_local_vector(Vector3(0,vert_vel.y,0))
		if(vert_side == 0):
			velocity -= global_to_local_vector(vert.get_angle(global_position).basis.z * vert_vel.x)
		elif(vert_side == 1):
			velocity -= global_to_local_vector(-vert.get_angle(global_position).basis.z * vert_vel.x)
			angle+=PI
			
		var point = $GravityRay.get_collision_point()
		position = point + basis.y * GROUND_OFFSET
		rotation = Quaternion(Vector3.UP, $GravityRay.get_collision_normal()).get_euler()
		rotate_object_local(Vector3.UP, angle)
		if(CLONE_WOOPER.ANIMATION_TREE["parameters/Kickflip/active"]):
			start_animation("Bail")
		return true
	return false

func drop_vert():
	velocity = global_to_local_vector(Vector3(0,vert_vel.y,0))
	velocity -= global_to_local_vector(vert.get_angle(global_position).basis.z * vert_vel.x)
	#velocity.z *= -1
	#velocity.y -= 1
	
	set_animation("Grinding", 0)
	airborne_angle = 0
	state = STATE.airborne
func drop_out_vert():
	
	velocity = global_to_local_vector(Vector3(0,vert_vel.y,0))
	velocity -= global_to_local_vector(vert.get_angle(global_position).basis.z * vert_vel.x)
	#velocity.z *= -1
	velocity.y -= 1
	#velocity.z += 1
	
	set_animation("Grinding", 0)
	airborne_angle = 0
	state = STATE.airborne
func check_vert():
	if(basis.z.y <= 0 && !(basis.z.y < 0 && velocity.z < -1)):
		return false
	for v in GameManager._vert:
		if(v == null):
			continue
		if(v.get_distance(global_position) < VERT_MAGNETISM):
			spine_lock = false
			var trans = v.get_angle(global_position)
			if(trans == null):
				continue
			
			state = STATE.vert
			vert = v
			offset = v.get_offset(global_position)
			vert_coords = Vector2(offset, 0)
			var ang = vert.get_angle(global_position)
			var dir = ang.basis.z
			vert_angle_offset = atan2(dir.z,dir.x)
			vert_dir = vert_angle_offset
			
			vert_side = 0
			if(ang.basis.x.dot(basis.y) < 0):
				vert_side = 1
			
			var comp_angle = (angle + vert_angle_offset) + PI/2
			vert_vel = Vector2(cos(comp_angle),sin(comp_angle)) * velocity.length()
			if(vert_side):
				vert_vel = Vector2(-cos(comp_angle + PI),sin(comp_angle + PI)) * velocity.length()
			
			vert_vel *= sign(velocity.z)
			
			#if d < 0:
				#velocity.z *= -1
			vert_timer = 0
			return true
	return false
	
var spine_lock = false
	
func check_vert_relative(pos):
	GameManager._vert.sort_custom(
		func(a, b):
			return a.get_distance(pos) < b.get_distance(pos)
			)
	for v in GameManager._vert:
		if(v == null):
			continue
		var closest_point : Vector3 = v.get_closest_point(pos)
		closest_point.y = pos.y
		var direction = (v.get_closest_point(pos) - global_position).normalized()
		if(closest_point.distance_to(pos) < 1 && v.get_closest_point(pos).y < global_position.y && direction.dot(local_to_global_vector(velocity).normalized()) > 0):
			var trans = v.get_angle(pos)
			if(trans == null):
				continue
			state = STATE.vert
			vert = v
			offset = v.get_offset(pos)
			vert_coords = Vector2(offset, v.get_distance(global_position))
			var ang = vert.get_angle(pos)
			var dir = ang.basis.z
			vert_angle_offset = atan2(dir.z,dir.x)
			vert_dir = vert_angle_offset
			
			vert_side = 0
			if(ang.basis.x.dot(local_to_global_vector(velocity)) < 0):
				vert_side = 1
			
			var comp_angle = (angle + vert_angle_offset) + PI/2
			velocity *= 0
			vert_vel = Vector2(cos(comp_angle),sin(comp_angle)) * velocity.length()
			if(vert_side):
				vert_vel = Vector2(-cos(comp_angle + PI),sin(comp_angle + PI)) * velocity.length()
			
			vert_vel *= sign(velocity.z)
			spine_lock = true
			#if d < 0:
				#velocity.z *= -1
			vert_timer = 0
			if(DEBUG_VERT):
				DebugDraw3D.draw_arrow(global_position, global_position + basis.y, Color.BLUE, DEBUG_ARROW_THICKNESS)
			return true
	return false

func get_vert_plane_angle():
	return vert.get_angle_offset(vert_vel.x)


func check_walls_vert(_delta):
	var movement = Vector2.ZERO
	var pushback = Vector2.ZERO
	var checks = $WallCheck.get_children()
	for c in checks:
		if(c.is_colliding()):
			var angle = vert.get_angle_offset(vert_vel.x)
			var point = c.get_collision_point()
			var distance = abs(c.target_position.y) - c.global_position.distance_to(point)
			var res = Vector2(-c.get_collision_normal().dot(angle.basis.z), c.get_collision_normal().dot(angle.basis.y)).normalized()
			movement += res * distance * 1.1
			pushback += res
			if(c.get_collision_normal().y > 0.5):
				drop_vert()
				rotation = Vector3.ZERO
				reset()
				return true
	vert_coords += movement
	vert_vel += pushback
	return false

func vert_physics(delta):
	manual = false
	if check_walls_vert(delta):
		return
	var input_dir = Input.get_vector("left", "right", "down", "up")
	var prev_angle = angle
	if(vert.get_angle_offset(vert_coords.x) == null):
		drop_vert()
		return
	var dir = vert.get_angle_offset(vert_coords.x).basis.z
	var old_offset = vert_angle_offset
	vert_angle_offset = atan2(dir.z,dir.x)
	prev_ground_angle = vert_angle_offset - PI/2
	vert_dir = vert_angle_offset
	
	var comp_angle = (angle + vert_angle_offset) + PI/2
	vert_vel.y -= GRAVITY * delta
	angle -= input_dir.x * AIR_TURN_SPEED * delta
	angle -= vert_angle_offset - old_offset
	vert_coords += vert_vel*delta
	if(vert.is_loop):
		if(vert_coords.x < 0):
			vert_coords.x = vert.get_baked_length() + vert_coords.x
		elif(vert_coords.x > vert.get_baked_length()):
			vert_coords.x = vert_coords.x - vert.get_baked_length() + 0
	if(vert.get_angle_offset(vert_coords.x) != null):
			
		rotation = Quaternion(Vector3.UP, vert.get_angle_offset(vert_coords.x).basis.x).get_euler()
		if(vert_side == 1):
			rotation = Quaternion(Vector3.UP, -vert.get_angle_offset(vert_coords.x).basis.x).get_euler()
		rotate_object_local(Vector3.UP, angle)
	#velocity *= 0.99
	position = vert.get_pos_from_offset(vert_coords.x)
	position.y += vert_coords.y 
	if(vert_timer > 0.1):
		if(snap_to_ground_vert()):
			return
	else:
		vert_timer += delta
		
	if(!vert.is_loop):
		if(vert_coords.x < 0 || vert_coords.x > vert.get_baked_length()):
			drop_vert()
	
	if(Input.is_action_just_pressed("drift") && !spine_lock):
		var space_state = get_world_3d().direct_space_state
		var scale = 0.5
		var query = PhysicsRayQueryParameters3D.create(position - basis.y * scale, (position - basis.y * scale) + Vector3(0,-100, 0))
		var result = space_state.intersect_ray(query)
		if(result.size() != 0):
			if(DEBUG_VERT):
				DebugDraw3D.draw_arrow(position - basis.y * 0.5, result["position"],Color.RED, DEBUG_ARROW_THICKNESS,false, 100)

			var layer = result["collider"].get_collision_layer()
			if(result["normal"].y > 0 && (layer == 4 || layer == 5)):
				if(vert_side == 1):
					vert_side = 0
				else:
					vert_side = 1 
				spine_lock = true
				
				to_rotation = Quaternion(Vector3.UP, vert.get_angle_offset(vert_coords.x).basis.x)
				if(vert_side == 1):
					to_rotation = Quaternion(Vector3.UP, -vert.get_angle_offset(vert_coords.x).basis.x)
				rotation = to_rotation.get_euler()
				vert_vel = Vector2.ZERO
				return
		if(!$GravityRay.is_colliding()):
			drop_out_vert()
		return
	if(InputBuffer.is_action_press_buffered("grind") && ! Input.is_action_pressed("jump")):
		check_rail()
	if(InputBuffer.is_action_press_buffered("trick") && !CLONE_WOOPER.ANIMATION_TREE["parameters/Kickflip/active"]):
		trick_animation()
	pass
	
