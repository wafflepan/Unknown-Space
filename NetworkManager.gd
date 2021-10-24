extends Node

const MAX_PLAYERS = 5

var players = {}

var my_info = { name = "Johnson Magenta", favorite_color = Color8(255, 0, 255) }
var my_network_id = null
#
#    network_peer_connected(int id)
#    network_peer_disconnected(int id)
#

var currentconnection = null

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

func checkPlayerList():
	print(players)

func _player_connected(id):
	print("Player_connected called on client ",get_tree().get_network_unique_id()," with id ",id)
	# Called on both clients and server when a peer connects. Send my info to it.
	rpc_id(id, "register_player", my_info)

remote func register_player(info):
	pass
	print("REGISTERPLAYER called on client ",get_tree().get_network_unique_id()," with info ",info)
	

func createServer(inputdict):
	setMyInfo(inputdict)
	players[1] = my_info
	my_network_id=1
	var peer = NetworkedMultiplayerENet.new()
	var error = peer.create_server(23399, MAX_PLAYERS)
	if error:
		print("Error creating server: ",error)
	get_tree().set_network_peer(peer)

func joinServer(inputdict):
	setMyInfo(inputdict)
	var peer = NetworkedMultiplayerENet.new()
	var error = peer.create_client(inputdict["Address"],23399)
	if error:
		print("Error joining server: ",error)
	get_tree().set_network_peer(peer)

func setMyInfo(inputdict):
	pass
	my_info = inputdict

func _player_disconnected(id):
	print("Player Disconnected called on client ",get_tree().get_network_unique_id()," with id ",id)
	players.erase(id) # Erase player from info.

func _connected_ok():
	my_network_id = get_tree().get_network_unique_id()
	print("connected_ok called on client ",get_tree().get_network_unique_id())
	rpc_id(1,"notifyPlayerConnection",my_network_id,my_info)
	pass # Only called on clients, not server. Will go unused; not useful here.

remote func notifyPlayerConnection(id,info):
	print("Client ",get_tree().get_network_unique_id()," notified of connection from client id ",id," with info ",info)
	players[id]=info

func _server_disconnected():
	print("server_diconnected called on client ",get_tree().get_network_unique_id())
	pass # Server kicked us; show error and abort.

func _connected_fail():
	print("connected_failed called on client ",get_tree().get_network_unique_id())
	pass # Could not even connect to server; abort.

func _process(delta):
	if get_tree().get_network_peer():
		rpc("connectionNotify",get_tree().get_network_unique_id(),my_info,randf())

remote func connectionNotify(id,info,number):
	pass
	print("Notification on client ",get_tree().get_network_unique_id()," by ",id, "  ",info,"  ", number)
