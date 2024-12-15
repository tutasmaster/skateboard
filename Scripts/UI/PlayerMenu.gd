extends Control
var open = false

func toggle_open():
	if(!open):
		#$AnimationPlayer.play("Open")
		show()
		$HBoxContainer/MarginContainer/VBoxContainer/Button.grab_focus()
		#reset_button.grab_focus()
	else:
		hide()
		#$AnimationPlayer.play("Close")
		get_viewport().gui_release_focus()
	open = !open
	GameManager.paused = open
