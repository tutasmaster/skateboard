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

func save_params():
	var save_game = FileAccess.open("user://" + params_line.text, FileAccess.WRITE)
	var json_string = JSON.stringify(SkateData.get_params())
	save_game.store_line(json_string)

func load_par(path):
	GameManager.current_config = "user://" + path
	params_line.text = path
	load_params_in_path("user://" + path)
				
func load_params_in_path(path):
	GameManager.load_params_in_path(path)
	var p = SkateData.get_params()
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

func toggle_pause():
	GameManager.paused = !GameManager.paused
	pass # Replace with function body.


func load_map(map):
	GameManager.load_map(map)

func hide_menu():
	$AnimationPlayer.play("Close")
	get_viewport().gui_release_focus()
	pass
