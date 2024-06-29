extends Node

var player : Node3D
var playerScript : Player
var camera : Node3D
var loot : PackedScene = preload("res://Scenes/loot.tscn")
var dmg_num : PackedScene = preload("res://Scenes/damage.tscn")
var clone_player : PackedScene = preload("res://Scenes/Skatepark/clone_wooper.tscn")
var _loot_player : AudioStreamPlayer

var _rails : Array[Node3D] = []

var _vert : Array[Node3D] = []

var paused = false

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
	_targets = []
	_loot_player = AudioStreamPlayer.new()
	_loot_player.stream = load("res://Assets/Sounds/powerup.wav")
	_loot_player.max_polyphony = 5
	_loot_player.volume_db = 0.5
	add_child(_loot_player)

func is_debug_rail():
	return player.DEBUG_GRIND

func toggle_menu():
	menu.toggle_open()

func reload():
	_targets = []
	_vert = []
	_rails = []
	paused = false
	get_tree().reload_current_scene()
	player.CLONE_WOOPER.showClothes()
	
func load_map(map):
	_targets = []
	_vert = []
	_rails = []
	paused = false
	var dict = {}
	if(_multiplayer_manager):
		dict = _multiplayer_manager.players
	for p in dict:
		dict[p].get_parent().remove_child(dict[p])
	get_tree().change_scene_to_file("res://Scenes/" + map)
	player.CLONE_WOOPER.showClothes()
	if(_multiplayer_manager):
		dict = _multiplayer_manager.players
		for p in dict:
			_multiplayer_manager.add_child(dict[p])

func play_loot_sound():
	_loot_player.pitch_scale = randf_range(0.2,1.8)
	_loot_player.play()

var _targets : Array[Node3D] = []	

func register_enemy(entity):
	_targets.push_back(entity)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
