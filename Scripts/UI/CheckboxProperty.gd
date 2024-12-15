extends HBoxContainer
class_name CheckboxProperty

var prop_name : String = "PROPERTY"
var prop_value : bool = false
@onready var value_box : CheckButton = $PROPERTY_VALUE
@onready var name_box : LineEdit = $PROPERTY_NAME
var menu = null
signal on_toggle

func _ready():
	name_box.text = prop_name
	value_box.set_pressed_no_signal(prop_value)

func _on_property_value_toggled(toggled_on):
	self.prop_value = toggled_on
	value_box.button_pressed = toggled_on
	on_toggle.emit(prop_name, prop_value)
	SkateData.update_property(prop_name, prop_value)
