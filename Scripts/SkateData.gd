extends Node

@export_subgroup("Mechanics")
@export var ACID_DROPS_ENABLED = true
@export var FLIPS_ENABLED = true
@export var MANUALS_ENABLED = true
@export var WALLPLANTS_ENABLED = true
@export var VERT_ENABLED = true
@export var AUTO_ALIGN_ENABLED = true
@export var VERT_WALLS_ENABLED = true

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
@export var JUMP_MINIMUM_ANIMATION_FACTOR = 0.1
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

@export_subgroup("Walk Properties")
@export var WALK_GRAVITY = 45
@export var WALK_FRICTION = 3
@export var WALK_TURN_SPEED = 5
@export var WALK_SPEED_CAP = 4.5
@export var WALK_ACCELERATION = 20
@export var WALK_JUMP_STRENGTH = 3

@export_subgroup("Visual Properties")
@export var LERP_SPEED = 20
@export var BALANCE_MANUAL_SCALE = 10
@export var BALANCE_GRIND_SCALE = 10
@export var BAIL_DRAG = 0.95

@export_subgroup("Multiplayer Properties")
@export var MP_INTERPOLATION_SPEED = 3
@export var MP_COLLISIONS_ENABLED = false


func get_params():
	var params = {
		"_ENABLED_MECHANICS" : "Mechanics",
		"ACID_DROPS_ENABLED" : ACID_DROPS_ENABLED,
		"FLIPS_ENABLED" : FLIPS_ENABLED,
		"MANUALS_ENABLED" : MANUALS_ENABLED,
		"WALLPLANTS_ENABLED" : WALLPLANTS_ENABLED,
		"VERT_ENABLED" : VERT_ENABLED,
		"AUTO_ALIGN_ENABLED" : AUTO_ALIGN_ENABLED,
		"VERT_WALLS_ENABLED" : VERT_WALLS_ENABLED,
		"_SPECIAL" : "Special Properties",
		"SLOW_MOTION" : SLOW_MOTION,
		"SPEED_CAP" : SPEED_CAP,
		"CRASH_VELOCITY" : CRASH_VELOCITY,
		"_Debug" : "Debug Properties",
		"DEBUG_ARROW_THICKNESS" : DEBUG_ARROW_THICKNESS,
		"DEBUG_WALLPLANTS" : DEBUG_WALLPLANTS,
		"DEBUG_VERT" : DEBUG_VERT,
		"DEBUG_GRIND" : DEBUG_GRIND,
		"DEBUG_DIRECTION" : DEBUG_DIRECTION,
		"DEBUG_NORMAL" : DEBUG_NORMAL,
		"_GROUND" : "Grounded Properties",
		"GRAVITY" : GRAVITY,
		"FRICTION" : FRICTION,
		"DRAG" : DRAG,
		"HORIZONTAL_DRAG" : HORIZONTAL_DRAG,
		"MINIMUM_SPEED" : MINIMUM_SPEED,
		"TURN_MULTIPLIER" : TURN_MULTIPLIER,
		"GROUND_OFFSET" : GROUND_OFFSET,
		"UP_SLOPE_ACCELERATION" : UP_SLOPE_ACCELERATION,
		"UP_VERT_SLOPE_ACCELERATION" : UP_VERT_SLOPE_ACCELERATION,
		"DOWN_SLOPE_ACCELERATION" : DOWN_SLOPE_ACCELERATION,
		"DOWN_VERT_SLOPE_ACCELERATION" : DOWN_VERT_SLOPE_ACCELERATION,
		"_DRIFT": "Drift Properties",
		"DRIFT_FORCE" : DRIFT_FORCE,
		"DRIFT_FORCE_DRAG" : DRIFT_FORCE_DRAG,
		"_JUMP" : "Jump Properties",
		"JUMP_ALWAYS_HOLD" : JUMP_ALWAYS_HOLD,
		"JUMP_FORCE" : JUMP_FORCE,
		"JUMP_VERT_FORCE" : JUMP_VERT_FORCE,
		"JUMP_TIMER" : JUMP_TIMER,
		"JUMP_HOLD_DRAG" : JUMP_HOLD_DRAG,
		"JUMP_HOLD_FRICTION" : JUMP_HOLD_FRICTION ,
		"JUMP_HOLD_SPEED" : JUMP_HOLD_SPEED,
		"JUMP_MINIMUM_FACTOR" : JUMP_MINIMUM_FACTOR,
		"JUMP_MINIMUM_ANIMATION_FACTOR" : JUMP_MINIMUM_ANIMATION_FACTOR,
		"_AIR" : "Airborne Properties",
		"AIR_TURN_SPEED" : AIR_TURN_SPEED,
		"WALLPLANT_DECAY_MULTIPLIER" : WALLPLANT_DECAY_MULTIPLIER,
		"VERT_MAGNETISM" : VERT_MAGNETISM,
		"AIR_TO_GROUND_MOMENTUM_LOSS" : AIR_TO_GROUND_MOMENTUM_LOSS,
		"AIR_TO_GROUND_SIDE_MOMENTUM_LOSS" : AIR_TO_GROUND_SIDE_MOMENTUM_LOSS,
		"_GRIND" : "Grind Properties",
		"GRIND_DRAG" : GRIND_DRAG,
		"GRIND_FRICTION" : GRIND_FRICTION,
		"GRIND_MAGNETISM" : GRIND_MAGNETISM,
		"UP_GRIND_SLOPE_ACCELERATION" : UP_GRIND_SLOPE_ACCELERATION,
		"DOWN_GRIND_SLOPE_ACCELERATION" : DOWN_GRIND_SLOPE_ACCELERATION,
		"MINIMUM_GRIND_SPEED" : MINIMUM_GRIND_SPEED,
		"_BALANCE" : "Balance Properties",
		"BALANCE_MIN_DIFFICULTY" : BALANCE_MIN_DIFFICULTY,
		"BALANCE_START_RANGE" : BALANCE_START_RANGE,
		"BALANCE_MULT_DIFFICULTY" : BALANCE_MULT_DIFFICULTY,
		"BALANCE_MULT_INPUT" : BALANCE_MULT_INPUT,		
		"BALANCE_MANUAL_MIN_DIFFICULTY" : BALANCE_MANUAL_MIN_DIFFICULTY,
		"BALANCE_MANUAL_START_RANGE" : BALANCE_MANUAL_START_RANGE,
		"BALANCE_MANUAL_MULT_DIFFICULTY" : BALANCE_MANUAL_MULT_DIFFICULTY,
		"BALANCE_MANUAL_MULT_INPUT" : BALANCE_MANUAL_MULT_INPUT,		
		"BALANCE_MANUAL_TURN_SPEED" : BALANCE_MANUAL_TURN_SPEED,		
		"BALANCE_MANUAL_DIFF_INCREASE" : BALANCE_MANUAL_DIFF_INCREASE,		
		"_WALK" : "Walk Properties",
		"WALK_GRAVITY" : WALK_GRAVITY,		
		"WALK_FRICTION" : WALK_FRICTION,		
		"WALK_TURN_SPEED" : WALK_TURN_SPEED,		
		"WALK_SPEED_CAP" : WALK_SPEED_CAP,		
		"WALK_ACCELERATION" : WALK_ACCELERATION,		
		"WALK_JUMP_STRENGTH" : WALK_JUMP_STRENGTH,
		"_LERP" : "Visual Properties",
		"LERP_SPEED" : LERP_SPEED,
		"BALANCE_MANUAL_SCALE" : BALANCE_MANUAL_SCALE,
		"BALANCE_GRIND_SCALE" : BALANCE_GRIND_SCALE,
		"BAIL_DRAG" : BAIL_DRAG,
		"KICK_FORCE" : KICK_FORCE,
		"_MP" : "Multiplayer Properties",
		"MP_INTERPOLATION_SPEED" : MP_INTERPOLATION_SPEED,
		"MP_COLLISIONS_ENABLED" : MP_COLLISIONS_ENABLED
	}
	return params

func update_property(name, value):
	set(name, value)
