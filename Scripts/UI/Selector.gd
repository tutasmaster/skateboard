extends Node2D

@export var options : Array[String]
@export var options_nodes : Array[Node2D]
@export var current_option : int

@export var option_prefab = preload("res://Scenes/UI/option.tscn")

@export var offset = Vector2(2000, 0)
@export var speed = 1

signal onOptionSelected(option : int)

func _ready():
	var i = 0
	for o in options:
		var option_object : Node2D = option_prefab.instantiate()
		option_object.setText(o)
		if(i != current_option):
			option_object.position = offset * sign(i - current_option)
		add_child(option_object)
		options_nodes.push_back(option_object)
		i += 1

func _process(delta: float) -> void:
	if(!visible):
		return
	if(Input.is_action_just_pressed("ui_left") || Input.is_action_just_pressed("ui_up")):
		current_option -= 1
	if(Input.is_action_just_pressed("ui_right") || Input.is_action_just_pressed("ui_down")):
		current_option += 1
	if(Input.is_action_just_pressed("ui_accept")):
		onOptionSelected.emit(current_option)
	current_option = clamp(current_option, 0, options.size()-1)
	
	var i = 0
	for o in options_nodes:
		o.position = o.position.lerp(offset * sign(i - current_option), min(1,delta * speed))
		i += 1
		
