extends Node

const MAX_PLAYERS:int = 5

signal update_connected_players
signal playerdisconnected
signal newplayerconnected
signal start_game

var SERVER_DISCONNECT_FLAG=false
var isGameStarted = false

var NETWORK_players:Dictionary = {} #List of players in lobby
var players_ready = []

var DEFAULT_ADDRESS:String= '73.240.25.244'
var DEFAULT_PORT:int = 23399

var my_info:Dictionary = { name = "Johnson Magenta", favorite_color = Color8(255, 0, 255) }
#
#    network_peer_connected(int id)
#    network_peer_disconnected(int id)
#2601:1c0:8100:17:6d7f:5764:d376:9408

remotesync func signalReady(id):
	if !id in players_ready:
		print("Recieved ready signal from ",id)
		players_ready.append(id)
	if players_ready.size() == NETWORK_players.size():
		print("All players loaded, starting game")
		rpc("gameLoadComplete")
	

remotesync func gameLoadComplete(): #Server tells all clients (and self) that the game can be unpaused
	get_tree().paused=false
	isGameStarted=true

var currentconnection = null

func getData():
	pass
	return my_info

remote func clientToServerNotification(id,alert):
	if multiplayer.is_network_server():
		print("SERVERNOTIFICATION: ",id,"  ",alert)
	else:
		print("Tried to issue server notification to a client from source ",id)

func _ready():
#	print("Menu Loading")
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
	NETWORK_players[1] = my_info
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
#		NETWORK_players[multiplayer.get_network_unique_id()]=my_info
	return error

remote func registerPlayer(id,info):
	print(multiplayer.get_network_unique_id(),": registerplayer called by ",id," ",info)
	NETWORK_players[id]=info
	rpc_id(id,"updatePlayerList",NETWORK_players)
	emit_signal("update_connected_players")
	if multiplayer.is_network_server() and isGameStarted:
		print("Game in progress, sending join-existing-game command to ",id)
		rpc_id(id,"serverStartCommand")
	emit_signal("newplayerconnected",id,info)

puppet func serverStartCommand(): #Server signals client to switch to gameworld
	print(multiplayer.get_network_unique_id(),": SERVER START COMMAND")
	emit_signal("start_game")

puppet func updatePlayerList(list):
	print(multiplayer.get_network_unique_id(),": Received list of current players from server: ",list)
	if multiplayer.is_network_server():
		print("Tried to send an updated player list to the server! WTF? ",multiplayer.get_rpc_sender_id())
		return
	NETWORK_players=list

func _player_connected(id): #Called by the connecting client on all clients
	pass
#	print("Player_Connected called by ID ",id," on client ",multiplayer.get_network_unique_id())
#	rpc("registerPlayer",multiplayer.get_network_unique_id(),my_info)#Send new client my info

func _player_disconnected(id):
	print("Player Disconnected: ",id)
	emit_signal("playerdisconnected",id) #Send the disconnect message first, then update connected players
	NETWORK_players.erase(id)
	emit_signal("update_connected_players")

func _connected_ok(): #Called by client on self to indicate good connection
	print("CONNECTED_OK, REGISTERPLAYER SIGNAL SENT TO SERVER")
	rpc_id(1,"registerPlayer",multiplayer.get_network_unique_id(),my_info)
#	print("Connected_OK called by ",multiplayer.get_network_unique_id()) #Only called on clients, not server. Useful for setting flags or maybe requesting game data?

func terminateConnection():
#	get_tree().call_deferred("set_network_peer",null)
	get_tree().set_network_peer(null)
	NETWORK_players={}

func _server_disconnected():
	SERVER_DISCONNECT_FLAG=true
	isGameStarted=false
	get_tree().change_scene("res://Menu.tscn")
	terminateConnection()
