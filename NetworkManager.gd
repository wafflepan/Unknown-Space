extends Node

const MAX_PLAYERS = 5

var players = {}

var selfdata = {}

var currentconnection = null

func getData():
	return selfdata

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func createServer(creatordata):
	selfdata["Username"] = creatordata["Username"]
	var peer = NetworkedMultiplayerENet.new()
	players[1] = creatordata
	var error = peer.create_server(int(creatordata["Port"]),int(MAX_PLAYERS))
	if error:
		print("ERROR CREATING SERVER: ",error)
	get_tree().set_network_peer(peer)

func joinServer(clientdata):
	selfdata["Username"] = clientdata["Username"]
	var peer = NetworkedMultiplayerENet.new()
	var error = peer.create_client((clientdata["Address"]), int(clientdata["Port"]))
	if error:
		print("ERROR JOINING SERVER")
	get_tree().set_network_peer(peer)

remote func register_player(info):
	print("Registering player: ",info)
	var id = get_tree().get_rpc_sender_id()
	players[id] = info
	
	var newplayer = get_tree().get_root().get_node("GameWorld").createNewPlayer(info)
	
	newplayer.set_network_master(id)

func getConnectionStatus():
	if currentconnection:
		print(currentconnection.get_connection_status())
		return currentconnection.get_connection_status()
	else:
		return null

func _server_disconnected():
	print("Server Disconnected!")
#	get_tree().quit()

func _connected_ok(id):
	print("connected ok: ",id)
	pass

func _connected_fail():
	pass
	print("Connection Could Not Be Completed.")

remote func sendPlayerInfo(id, data):
	if get_tree().is_network_server():
		for peer in players:
			rpc_id(id,'sendPlayerInfo',peer,players[peer])
	players[id] = data
	
	var newplayer = get_tree().get_root().get_node("GameWorld").createNewPlayer(data)
	
	newplayer.set_network_master(id)

func _player_connected(id):
	print("Player Connected Ok ",get_tree().get_network_unique_id(),"  ",id)
	players[get_tree().get_network_unique_id()] = selfdata
#	rpc('sendPlayerInfo',get_tree().get_network_unique_id(),selfdata)
	rpc_id(id,"register_player",selfdata)
