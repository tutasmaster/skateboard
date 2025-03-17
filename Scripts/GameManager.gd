extends Node

var player : Node3D
var playerScript : Player
var camera : Node3D
var clone_player : PackedScene = preload("res://Scenes/Skatepark/clone_wooper.tscn")
var _loot_player : AudioStreamPlayer

var _rails : Array[Node3D] = []

var _vert : Array[Node3D] = []

var paused = false

var menu_prefab : PackedScene = preload("res://Scenes/Skatepark/Menu.tscn")

var menu : Control
var menu_anim : AnimationPlayer
var current_config = "res://Params/custom.json"

@onready var _multiplayer_manager = get_node("/root/MultiplayerManager")

var clothing = {
	"Helmet" = false,
	"Maid Dress" = false,
	"Maid Hat" = false,
	"TopHat" = false,
	"Eyes" = false,
	"Axolotl" = false,
	"Stache" = false
}

# Called when the node enters the scene tree for the first time.
func _ready():
	_rails = []
	#add_child(_loot_player)

func is_debug_rail():
	return SkateData.DEBUG_GRIND
	
func is_debug_vert():
	return SkateData.DEBUG_VERT

func toggle_menu():
	menu.toggle_open()

func reload():
	_vert = []
	_rails = []
	paused = false
	get_tree().reload_current_scene()
	player.CLONE_WOOPER.showClothes()

func start_freeskate(map):
	var m = menu_prefab.instantiate()
	add_child(m)
	menu = m
	load_map(map)

func load_map(map):
	_vert = []
	_rails = []
	paused = false
	var dict = {}
	if(_multiplayer_manager):
		dict = _multiplayer_manager.players
	for p in dict:
		dict[p].get_parent().remove_child(dict[p])
	get_tree().change_scene_to_file("res://Scenes/" + map)
	#player.CLONE_WOOPER.showClothes()
	if(_multiplayer_manager):
		dict = _multiplayer_manager.players
		for p in dict:
			_multiplayer_manager.add_child(dict[p])
	
	load_params_in_path(current_config)


func load_par(path):
	GameManager.current_config = "user://" + path
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
		for i in node_data.keys():
			print(i + " : " + str(node_data[i]))
			if(!i.begins_with("_")):
				SkateData.set(i, node_data[i])

func reset():
	reload()
	

func load_heavy():
	load_par("heavy.json")

func load_default():
	load_par("default.json")
