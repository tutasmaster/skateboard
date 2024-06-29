extends Control
@export var reset_button : Button
@export var params_line : LineEdit
@export var float_property : PackedScene
@export var checkbox_property : PackedScene
@export var property_category : PackedScene
@onready var property_container = $"HBoxContainer/MarginContainer/ScrollContainer/PROPERTY_CONTAINER"
@onready var clothes_container = $"HBoxContainer/AspectRatioContainer2/VBoxContainer/ScrollContainer/CLOTHES_CONTAINER"
@onready var _multiplayer_manager = get_node("/root/MultiplayerManager")
var open = false
# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.menu = self
	GameManager.menu_anim = $AnimationPlayer
	get_viewport().gui_release_focus()
	params_line.text = "default.json"
	load_params_in_path(GameManager.current_config)
	#load_params()
	load_clothes()
	pass # Replace with function body.

func load_clothes():
	var params = GameManager.clothing
	for i in params:
		if(i.begins_with("_")):
			var prop : PropertyCategory = property_category.instantiate()
			prop.prop_name = params[i]
			clothes_container.add_child(prop)
			continue
		if(params[i] is float || params[i] is int):
			var prop : FloatProperty = float_property.instantiate()
			prop.prop_value = params[i]
			prop.prop_name = i
			prop.menu = self
			clothes_container.add_child(prop)
		elif(params[i] is bool):
			var prop : CheckboxProperty = checkbox_property.instantiate()
			prop.prop_value = params[i]
			prop.prop_name = i
			prop.on_toggle.connect(pick_clothes)
			clothes_container.add_child(prop)
	
func pick_clothes(name, value):
	GameManager.clothing[name] = value
	GameManager.player.CLONE_WOOPER.showClothes()
	if(_multiplayer_manager):
		_multiplayer_manager.updatePlayerClothes.rpc(name,value)

func toggle_open():
	if(!open):
		$AnimationPlayer.play("Open")
		reset_button.grab_focus()
	else:
		$AnimationPlayer.play("Close")
		get_viewport().gui_release_focus()
	open = !open
	GameManager.paused = open

func get_params():
	var params = {
		"_SPECIAL" : "Special Properties",
		"SLOW_MOTION" : GameManager.player.SLOW_MOTION,
		"SPEED_CAP" : GameManager.player.SPEED_CAP,
		"CRASH_VELOCITY" : GameManager.player.CRASH_VELOCITY,
		"_Debug" : "Debug Properties",
		"DEBUG_ARROW_THICKNESS" : GameManager.player.DEBUG_ARROW_THICKNESS,
		"DEBUG_WALLPLANTS" : GameManager.player.DEBUG_WALLPLANTS,
		"DEBUG_VERT" : GameManager.player.DEBUG_VERT,
		"DEBUG_GRIND" : GameManager.player.DEBUG_GRIND,
		"DEBUG_DIRECTION" : GameManager.player.DEBUG_DIRECTION,
		"DEBUG_NORMAL" : GameManager.player.DEBUG_NORMAL,
		"_GROUND" : "Grounded Properties",
		"GRAVITY" : GameManager.player.GRAVITY,
		"FRICTION" : GameManager.player.FRICTION,
		"DRAG" : GameManager.player.DRAG,
		"HORIZONTAL_DRAG" : GameManager.player.HORIZONTAL_DRAG,
		"MINIMUM_SPEED" : GameManager.player.MINIMUM_SPEED,
		"TURN_MULTIPLIER" : GameManager.player.TURN_MULTIPLIER,
		"GROUND_OFFSET" : GameManager.player.GROUND_OFFSET,
		"UP_SLOPE_ACCELERATION" : GameManager.player.UP_SLOPE_ACCELERATION,
		"UP_VERT_SLOPE_ACCELERATION" : GameManager.player.UP_VERT_SLOPE_ACCELERATION,
		"DOWN_SLOPE_ACCELERATION" : GameManager.player.DOWN_SLOPE_ACCELERATION,
		"DOWN_VERT_SLOPE_ACCELERATION" : GameManager.player.DOWN_VERT_SLOPE_ACCELERATION,
		"_DRIFT": "Drift Properties",
		"DRIFT_FORCE" : GameManager.player.DRIFT_FORCE,
		"DRIFT_FORCE_DRAG" : GameManager.player.DRIFT_FORCE_DRAG,
		"_JUMP" : "Jump Properties",
		"JUMP_ALWAYS_HOLD" : GameManager.player.JUMP_ALWAYS_HOLD,
		"JUMP_FORCE" : GameManager.player.JUMP_FORCE,
		"JUMP_VERT_FORCE" : GameManager.player.JUMP_VERT_FORCE,
		"JUMP_TIMER" : GameManager.player.JUMP_TIMER,
		"JUMP_HOLD_DRAG" : GameManager.player.JUMP_HOLD_DRAG,
		"JUMP_HOLD_FRICTION" : GameManager.player.JUMP_HOLD_FRICTION ,
		"JUMP_HOLD_SPEED" : GameManager.player.JUMP_HOLD_SPEED,
		"JUMP_MINIMUM_FACTOR" : GameManager.player.JUMP_MINIMUM_FACTOR,
		"_AIR" : "Airborne Properties",
		"AIR_TURN_SPEED" : GameManager.player.AIR_TURN_SPEED,
		"WALLPLANT_DECAY_MULTIPLIER" : GameManager.player.WALLPLANT_DECAY_MULTIPLIER,
		"VERT_MAGNETISM" : GameManager.player.VERT_MAGNETISM,
		"AIR_TO_GROUND_MOMENTUM_LOSS" : GameManager.player.AIR_TO_GROUND_MOMENTUM_LOSS,
		"AIR_TO_GROUND_SIDE_MOMENTUM_LOSS" : GameManager.player.AIR_TO_GROUND_SIDE_MOMENTUM_LOSS,
		"_GRIND" : "Grind Properties",
		"GRIND_DRAG" : GameManager.player.GRIND_DRAG,
		"GRIND_FRICTION" : GameManager.player.GRIND_FRICTION,
		"GRIND_MAGNETISM" : GameManager.player.GRIND_MAGNETISM,
		"UP_GRIND_SLOPE_ACCELERATION" : GameManager.player.UP_GRIND_SLOPE_ACCELERATION,
		"DOWN_GRIND_SLOPE_ACCELERATION" : GameManager.player.DOWN_GRIND_SLOPE_ACCELERATION,
		"MINIMUM_GRIND_SPEED" : GameManager.player.MINIMUM_GRIND_SPEED,
		"_BALANCE" : "Balance Properties",
		"BALANCE_MIN_DIFFICULTY" : GameManager.player.BALANCE_MIN_DIFFICULTY,
		"BALANCE_START_RANGE" : GameManager.player.BALANCE_START_RANGE,
		"BALANCE_MULT_DIFFICULTY" : GameManager.player.BALANCE_MULT_DIFFICULTY,
		"BALANCE_MULT_INPUT" : GameManager.player.BALANCE_MULT_INPUT,		
		"BALANCE_MANUAL_MIN_DIFFICULTY" : GameManager.player.BALANCE_MANUAL_MIN_DIFFICULTY,
		"BALANCE_MANUAL_START_RANGE" : GameManager.player.BALANCE_MANUAL_START_RANGE,
		"BALANCE_MANUAL_MULT_DIFFICULTY" : GameManager.player.BALANCE_MANUAL_MULT_DIFFICULTY,
		"BALANCE_MANUAL_MULT_INPUT" : GameManager.player.BALANCE_MANUAL_MULT_INPUT,		
		"BALANCE_MANUAL_TURN_SPEED" : GameManager.player.BALANCE_MANUAL_TURN_SPEED,		
		"BALANCE_MANUAL_DIFF_INCREASE" : GameManager.player.BALANCE_MANUAL_DIFF_INCREASE,		
		"_LERP" : "Visual Properties",
		"LERP_SPEED" : GameManager.player.LERP_SPEED,
		"BAIL_DRAG" : GameManager.player.BAIL_DRAG,
		"KICK_FORCE" : GameManager.player.KICK_FORCE,
		"_MP" : "Multiplayer Properties",
		"MP_INTERPOLATION_SPEED" : GameManager.player.MP_INTERPOLATION_SPEED,
		"MP_COLLISIONS_ENABLED" : GameManager.player.MP_COLLISIONS_ENABLED
	}
	return params

func save_params():
	var save_game = FileAccess.open("user://" + params_line.text, FileAccess.WRITE)
	var json_string = JSON.stringify(get_params())
	save_game.store_line(json_string)

func load_par(path):
	GameManager.current_config = "user://" + path
	params_line.text = path
	load_params_in_path("user://" + path)
				
func load_params_in_path(path):
	if not FileAccess.file_exists(path):
		return # Error! We don't have a save to load.
	var save_game = FileAccess.open(path, FileAccess.READ)
	if save_game.get_position() < save_game.get_length():
		var json_string = save_game.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			return
		var node_data = json.get_data()
		for n in property_container.get_children():
			property_container.remove_child(n)
			n.queue_free()
		for i in node_data.keys():
			print(i + " : " + str(node_data[i]))
			if(!i.begins_with("_")):
				GameManager.player.set(i, node_data[i])
		var p = get_params()
		for i in p:
			if(i.begins_with("_")):
				var prop : PropertyCategory = property_category.instantiate()
				prop.prop_name = p[i]
				property_container.add_child(prop)
				continue
			if(p[i] is float || p[i] is int):
				var prop : FloatProperty = float_property.instantiate()
				prop.prop_value = p[i]
				prop.prop_name = i
				prop.menu = self
				property_container.add_child(prop)
			elif(p[i] is bool):
				var prop : CheckboxProperty = checkbox_property.instantiate()
				prop.prop_value = p[i]
				prop.prop_name = i
				prop.menu = self
				property_container.add_child(prop)
				

func load_params():
	load_par(params_line.text)
	
func update_property(name, value):
	GameManager.player.set(name, value)

func reset():
	GameManager.reload()

func load_heavy():
	load_par("heavy.json")

func load_default():
	load_par("default.json")


func toggle_pause():
	GameManager.paused = !GameManager.paused
	pass # Replace with function body.


func load_map(map):
	GameManager.load_map(map)

func hide_menu():
	$AnimationPlayer.play("Close")
	get_viewport().gui_release_focus()
	pass
