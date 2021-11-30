extends Node2D

var localdata = {"Username":"TestPlayer"}

var primaryplayer

var activeplayers = {} #Players currently connected to the session
var dormantplayers = {} #Players who were connected previously, and might rejoin

onready var primarygrid = $YSort/WallTiles

func _ready():#Create client player
	randomize()
#	get_tree().paused=true
	loadAllPlayersFromLobby() #spawn all players that connected before the game started
	NetworkManager.connect("playerdisconnected",self,"removePlayer")
	NetworkManager.connect("newplayerconnected",self,"createNewPlayer")
	NetworkManager.rpc_id(1,"signalReady",multiplayer.get_network_unique_id())
	setRestorePoint()

func getSyncData():
	var data = {}
	#Supply a dictionary of all objects in the 'sync' group, and their properties
	for object in $YSort/Entities.get_children():
		var datadict = {}
		datadict["position"]=object.position
		data[object] = datadict
	return data

var restore_point:Dictionary = {}

func setRestorePoint():
	restore_point = getSyncData()

func applySyncData(data):
	pass
	#Take dictionary of synchronization data and apply it to all nodes.
	for entity in data.keys():
#		print(entity,data[entity]["position"],entity.position)
		for property in data[entity]:
			entity.set(property,data[entity][property])
		

func applyDataToNode(entry:Dictionary):
	var targetnode:Node = entry["Node"]
	entry.erase("Node")
	for item in entry.keys():
		if item in targetnode:
			targetnode.item=entry[item]

func loadAllPlayersFromLobby(): #Take list of currently connected peers, create a player puppet for each of them
	print("LoadAllLobbyPlayers")
	for player in NetworkManager.NETWORK_players:
		var newplayer = createNewPlayer(player,NetworkManager.NETWORK_players[player])
		if player == multiplayer.get_network_unique_id(): #If self client
			primaryplayer=newplayer #Set main character
			var controller = load("res://PlayerInputComponent.tscn").instance()
			newplayer.add_child(controller)
			controller.connectToInventoryUI($UI/HoldingGrid)
			controller.setRightClickCanvasLayer($MenuLayer)
			var camera = $Camera2D
			remove_child(camera)
			newplayer.add_child(camera)
	if primaryplayer==null:
		var errstring = str("One of the connected clients does not have its own player!",multiplayer.get_network_unique_id())
		print(errstring)
		NetworkManager.rpc_id(1,"clientToServerNotification",errstring)

func createNewPlayer(id,data):
	print("Client ",multiplayer.get_network_unique_id(),": CreateNewPlayer: ",id,"  ",data)
	if data.size():
		localdata = data
	var newplayer= load("res://Actor.tscn").instance()
	newplayer.name = str(id)
	newplayer.position = Vector2(40,0).rotated(rand_range(-3,3)) #TODO: a 'getclearspot' function for spawning entities
	newplayer.setDisplayName(data["Username"])
	newplayer.set_network_master(id) #Set client as master of all its representations
	$YSort/Entities.add_child(newplayer)
	return newplayer

func on_object_spawn_request(obj,pos):
	var newinstance = obj.instance()
	newinstance.global_position = pos
	$YSort/Entities.add_child(newinstance) #TODO: Synchronize with peers

func _unhandled_input(event):
	if event is InputEventKey:
		if event.scancode == KEY_R:
			if event.is_pressed() and multiplayer.is_network_server():
				rpc("syncGameWorld",restore_point)

remotesync func syncGameWorld(data):
	applySyncData(data)

func removePlayer(id):
	var player = $YSort/Entities.get_node(str(id))
	player.dropAllItems()
#	$YSort/Entities.remove_child(player)
	player.queue_free()
	#Delete a player that's disconnected

func getGrid():
	return primarygrid
