extends "res://Scripts/UI/ScreenScaling.gd"

func _process(delta: float) -> void:
	super._process(delta)


func _on_selection(option: int) -> void:
	if option == 0:
		GameManager.start_freeskate("skatepark2.tscn")
	if option == 2:
		get_tree().quit()
