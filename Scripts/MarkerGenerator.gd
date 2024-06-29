@tool
extends Node3D
class_name MarkerGenerator

enum Type{
	NONE,
	VERT,
	RAIL,
	BOTH
}

enum Shape{
	CIRCLE
}

@export_category("Shape")
@export var shape : Shape = Shape.CIRCLE
@export var shape_size : float = 1
@export var detail : int = 32

@export_category("Trigger")
@export var type : Type = Type.NONE
@export var is_loop = false;
@export var fall_on_low_speed = false;

@export_category("Start")
@export var trigger : bool = false
var root = self

func make_circle(size, detail):
	var angle = (2 * PI)/detail
	for i in detail:
		var marker = Marker3D.new()
		root.add_child(marker)
		marker.position = Vector3(cos(i * angle) * size,0,sin(i * angle) * size)
		marker.owner = get_tree().edited_scene_root
	if(is_loop):
		var marker = Marker3D.new()
		root.add_child(marker)
		marker.position = Vector3(cos(0) * size,0,sin(0) * size)
		marker.owner = get_tree().edited_scene_root

func _process(delta):
	if(Engine.is_editor_hint()):
		if(trigger):
			if(type == Type.RAIL):
				var trigger = VertTrigger.new()
				trigger.type = VertTrigger.TYPE.RAIL
				trigger.is_loop = is_loop;
				trigger.fall_on_low_speed = fall_on_low_speed;
				add_child(trigger)
				trigger.owner = get_tree().edited_scene_root
				root = trigger
			elif(type == Type.VERT):
				var trigger = VertTrigger.new()
				trigger.type = VertTrigger.TYPE.VERT
				trigger.is_loop = is_loop;
				trigger.fall_on_low_speed = fall_on_low_speed;
				add_child(trigger)
				trigger.owner = get_tree().edited_scene_root
				root = trigger
			elif(type == Type.BOTH):
				var trigger = VertTrigger.new()
				trigger.type = VertTrigger.TYPE.BOTH
				trigger.is_loop = is_loop;
				trigger.fall_on_low_speed = fall_on_low_speed;
				add_child(trigger)
				trigger.owner = get_tree().edited_scene_root
				root = trigger
			else:
				root = self
			
			if(shape == Shape.CIRCLE):
				make_circle(shape_size, detail)
			trigger = false
	pass
