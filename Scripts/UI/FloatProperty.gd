extends HBoxContainer
class_name FloatProperty

var prop_name : String = "PROPERTY"
var prop_value : float = 0.0
@onready var value_box = $PROPERTY_VALUE
@onready var name_box : LineEdit = $PROPERTY_NAME
var menu = null

func _ready():
	name_box.text = prop_name
	value_box.value = prop_value

func _on_spin_box_value_changed(value):
	self.prop_value = value
	SkateData.update_property(prop_name, prop_value)
