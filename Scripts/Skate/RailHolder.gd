@tool
extends Node3D
class_name RailHolder

@export var is_loop = false;
@export var fall_on_low_speed = false;
@export var speedup = 0;

@export var pointList : Array[Vector3]
@export var curve : Curve3D
func _ready():
	if !Engine.is_editor_hint():
		GameManager._rails.push_back(self)
		pointList = []
		curve = Curve3D.new()
		curve.up_vector_enabled = true
		for c in get_children():
			pointList.push_back(c.global_position)
		for p in pointList:
			curve.add_point(p)
	pass # Replace with function body.


func get_distance(position):
	return (position - curve.get_closest_point(position)).length()

func get_closest_point(position):
	var offset = curve.get_closest_offset(position)
	if(offset == 0):
		return curve.sample_baked(curve.get_baked_length() - 0.1)
	return curve.get_closest_point(position)
	
func normalizeOffset(offset):
	while(offset > curve.get_baked_length() || offset < -curve.get_baked_length()):
		offset += -sign(offset) * curve.get_baked_length()
	return offset
	
func get_closest_point_offset(offset):
	if(is_loop):
		offset = normalizeOffset(offset)
		if(offset < 0):
			offset = curve.get_baked_length()+offset
		elif(offset > curve.get_baked_length()):
			offset = offset - curve.get_baked_length() + 0
	else:
		if(offset < 0 || offset > curve.get_baked_length()):
			return null
	return curve.sample_baked(offset)
	
func get_angle(position):
	var offset = curve.get_closest_offset(position)
	return curve.sample_baked_with_rotation(offset, true, false)
	
func get_angle_offset(offset):
	if(is_loop):
		offset = normalizeOffset(offset)
		if(offset < 0):
			offset = curve.get_baked_length()+offset
		elif(offset > curve.get_baked_length()):
			offset = offset - curve.get_baked_length() + 0
	else:
		if(offset < 0 || offset > curve.get_baked_length()):
			return null
	return curve.sample_baked_with_rotation(offset, true, false)

func get_offset(position):
	return curve.get_closest_offset(position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.is_editor_hint():
		pointList = []
		var curve : Curve3D = Curve3D.new()
		for c in get_children():
			pointList.push_back(c.global_position)
		for p in pointList:
			curve.add_point(p)
		DebugDraw3D.draw_line_path(pointList, Color.BLUE)
	else:
		if(GameManager.is_debug_rail()):
			DebugDraw3D.draw_line_path(pointList, Color.BLUE)
		
	pass
