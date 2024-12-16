extends Node

var scene = preload("res://Scenes/multiplayer.tscn")

var networking = false
var connected_to_server = false
var is_server = false

var multiplayer_menu : Control = null

var base_clothing = {
	"Helmet" = false,
	"Maid Dress" = false,
	"Maid Hat" = false,
	"TopHat" = false,
	"Eyes" = false
}

func _ready():
	set_multiplayer_authority(1)
	GameManager.paused = true
	multiplayer_menu = scene.instantiate()
	add_child(multiplayer_menu)
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	multiplayer.server_disconnected.connect(_server_disconnected)
	multiplayer.connection_failed.connect(_connection_failed)
	multiplayer.connected_to_server.connect(_connected_to_server)

func hostServer(_ip,port,_nickname="PLAYER"):
	if(connected_to_server):
		print("WON'T JOIN A SERVER WHILE CURRENTLY CONNECTED")
		return
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(int(port));
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		print("FAILED TO START SERVER")
	else:
		is_server = true
		print("STARTED A SERVER")
		multiplayer.multiplayer_peer = peer;
		networking = true
		multiplayer_menu.hide()
		return

func joinServer(ip,port,nickname="PLAYER"):
	if(connected_to_server):
		print("WON'T JOIN A SERVER WHILE CURRENTLY CONNECTED")
		return
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip,int(port))
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		print("FAILED TO START CLIENT")
		return
	else:
		print("JOINED " + ip + ":" + port)
		multiplayer.multiplayer_peer = peer
		networking = true
		multiplayer_menu.hide()

func _peer_connected(id):
	print("PEER CONNECTED " + str(id))
	if(id == 1):
		connected_to_server = true
		createPlayer(id)
	if(is_server):
		createPlayer(id)
		for p in players.keys():
			for c in players[p].clothes.keys():
				updatePlayerClothesId.rpc_id(id, p, c, players[p].clothes[c])
		for c in GameManager.clothing.keys():
			updatePlayerClothesId.rpc_id(id, 1, c, GameManager.clothing[c])
		#spawn_player(id)
		#SCENE_MULTIPLAYER.updatePlayerCount.rpc(game.players.size())
		#settings_scene.setPlayerCount(game.players.size())
		pass
	
func _peer_disconnected(id):
	print("PEER DISCONNECTED " + str(id))
	if(id == 1):
		connected_to_server = false
		return
	if(is_multiplayer_authority()):
		pass
	if(players.has(id)):
		players[id].queue_free()
		players.erase(id)
		#var step = 0
		#for p in game.players:
			#if(p.networkId == id):
				#p.playerObject.queue_free()
				#game.players.remove_at(step)
				#break
			#step+=1
		#syncTable()
		#syncHands()
		#settings_scene.setPlayerCount(game.players.size())
	#pass
	
func _server_disconnected():
	print("SERVER DISCONNECTED")
	networking = false
	multiplayer.multiplayer_peer = null
	connected_to_server = false
	#if(SCENE_MULTIPLAYER != null):
		#SCENE_MULTIPLAYER.queue_free()
	
	#SCENE_MAIN_MENU = load("res://Scenes/MainMenu.tscn").instantiate()
	#get_tree().root.add_child.call_deferred(SCENE_MAIN_MENU)
	#SCENE_MAIN_MENU.name = "MM"
	#print(SCENE_MAIN_MENU)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().reload_current_scene()
	pass
	
func _connection_failed():
	print("CONNECTION FAILED")
	networking = false
	connected_to_server = false
	#if(SCENE_MULTIPLAYER != null):
		#SCENE_MULTIPLAYER.queue_free()
	pass


func _connected_to_server():
	print("CONNECTED TO SERVER")
	networking = true
	connected_to_server = true
	#if(SCENE_MAIN_MENU != null):
		#SCENE_MAIN_MENU.queue_free()
	#SCENE_MULTIPLAYER = load("res://Scenes/Multiplayer.tscn").instantiate()
	#get_tree().root.add_child(SCENE_MULTIPLAYER)
	

var players = {
	#"local" : GameManager.player
}	

func _process(delta):
	if(GameManager.player):
		updatePlayer.rpc(GameManager.player.position, GameManager.player.rotation)

func createPlayer(id):
	players[id] = GameManager.clone_player.instantiate()
	players[id].clothes = base_clothing.duplicate()
	if(GameManager.player != null && SkateData.MP_COLLISIONS_ENABLED):
		players[id].enable_collisions()
	add_child(players[id])
	

@rpc("any_peer","unreliable_ordered")
func updatePlayer(position, rotation):
	var id = multiplayer.get_remote_sender_id()
	if(!players.has(id)):
		createPlayer(id)
		
	players[id].target_position = position
	players[id].target_rotation = rotation
		

@rpc("any_peer","unreliable_ordered")
func updatePlayerAnimation(animation_string, value):
	if(players.has(multiplayer.get_remote_sender_id())):
		players[multiplayer.get_remote_sender_id()].ANIMATION_TREE[animation_string] = value
		
		
@rpc("any_peer","reliable")
func updatePlayerClothes(cloth, value):
	var id = multiplayer.get_remote_sender_id()
	if(players.has(id)):
		players[id].clothes[cloth] = value
		players[id].showClothes()
	
@rpc("any_peer","reliable")
func updatePlayerClothesId(id, cloth, value):
	if(players.has(id)):
		players[id].clothes[cloth] = value
		players[id].showClothes()
	
