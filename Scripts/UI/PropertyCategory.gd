extends HBoxContainer
class_name PropertyCategory

@onready var name_box : Label = $PROPERTY_NAME
var prop_name : String = "PROPERTY_NAME"

func _ready():
	name_box.text = prop_name
