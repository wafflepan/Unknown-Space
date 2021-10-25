extends Node

const MAX_PLAYERS:int = 5

signal update_connected_players
signal playerdisconnected
signal newplayerconnected

var SERVER_DISCONNECT_FLAG=false

var players:Dictionary = {} #List of players in lobby

var DEFAULT_ADDRESS:String= '73.240.25.244'
var DEFAULT_PORT:int = 60000

var my_info:Dictionary = { name = "Johnson Magenta", favorite_color = Color8(255, 0, 255) }
#
#    network_peer_connected(int id)
#    network_peer_disconnected(int id)
#2601:1c0:8100:17:6d7f:5764:d376:9408

var currentconnection = null

func getData():
	pass
	return my_info

remote func clientToServerNotification(alert):
	if multiplayer.is_network_server():
		print("SERVERNOTIFICATION: ",alert)
	else:
		print("Tried to issue server notification to a client.")

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	var timer = Timer.new()
	timer.wait_time=4
	timer.connect("timeout",self,"checkPlayerList")
	self.add_child(timer)
	timer.start()

func createServer(inputdict):
	my_info = (inputdict)
	players[1] = my_info
	var peer = NetworkedMultiplayerENet.new()
	var error = peer.create_server(int(inputdict["Port"]), MAX_PLAYERS)
	if error:
		print("Error creating server: ",error)
	else:
		get_tree().set_network_peer(peer)
	return error

func checkPlayerList():
	if multiplayer.network_peer:
		return multiplayer.get_network_connected_peers()

func joinServer(inputdict):
	my_info = inputdict
	var peer = NetworkedMultiplayerENet.new()
	var error = peer.create_client(inputdict["Address"],int(inputdict["Port"]))
	if error:
		print("Error joining server: ",error)
	else:
		get_tree().set_network_peer(peer)
	return error

remotesync func registerPlayer(id,info):
	print(multiplayer.get_network_unique_id(),": registerplayer ",id," ",info)
	players[id]=info
	emit_signal("update_connected_players")
	emit_signal("newplayerconnected",id,info)

func _player_connected(id):
	print("Player_Connected called by ID ",id," on client ",multiplayer.get_network_unique_id())
	rpc("registerPlayer",multiplayer.get_network_unique_id(),my_info)#Send new client my info

func _player_disconnected(id):
	print("Player Disconnected: ",id)
	players.erase(id)
	emit_signal("update_connected_players")
	emit_signal("playerdisconnected",id)

func _connected_ok():
	pass
	print("Connected_OK called by ",multiplayer.get_network_unique_id()) #Only called on clients, not server. Useful for setting flags or maybe requesting game data?

func terminateConnection():
	get_tree().network_peer=null

func _server_disconnected():
	get_tree().network_peer=null
	SERVER_DISCONNECT_FLAG=true
	get_tree().change_scene("res://Menu.tscn")
