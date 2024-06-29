extends Node

@export var ip_address : LineEdit
@export var port : LineEdit
@export var nickname : LineEdit

@onready var _multiplayer_manager = get_node("/root/MultiplayerManager")

var selectedAppearance = 0


func JoinGame():
	if(_multiplayer_manager):
		_multiplayer_manager.joinServer(ip_address.text,port.text,nickname.text)
	pass
	
func HostGame():
	if(_multiplayer_manager):
		_multiplayer_manager.hostServer(ip_address.text,port.text,nickname.text)
	pass
