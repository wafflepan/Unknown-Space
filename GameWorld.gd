extends Node2D

var localdata = {"Username":"TestPlayer"}

var primaryplayer

var activeplayers = {} #Players currently connected to the session
var dormantplayers = {} #Players who were connected previously, and might rejoin

onready var primarygrid = $YSort/WallTiles

func _ready():#Create client player
	loadAllPlayersFromLobby()
	NetworkManager.connect("playerdisconnected",self,"removePlayer")

func loadAllPlayersFromLobby():
	for player in NetworkManager.players:
		var newplayer = createNewPlayer(NetworkManager.players[player],player)
		newplayer.set_network_master(player) #Set client as master of all its representations
		if player == multiplayer.get_network_unique_id(): #If self client
			primaryplayer=newplayer #Set main character
			var camera = $Camera2D
			remove_child(camera)
			newplayer.add_child(camera)
	if primaryplayer==null:
		var errstring = str("One of the connected clients does not have its own player!",multiplayer.get_network_unique_id())
		print(errstring)
		NetworkManager.rpc_id(1,"clientToServerNotification",errstring)

func createNewPlayer(data,id):
	if data.size():
		localdata = data
	var newplayer= load("res://Actor.tscn").instance()
	newplayer.name = str(id)
	newplayer.position = Vector2(10,0).rotated(rand_range(-3,3))
	newplayer.setDisplayName(data["Username"])
	$YSort/Entities.add_child(newplayer)
	return newplayer

func removePlayer(id):
	pass
	#Delete a player that's disconnected

func getGrid():
	return primarygrid
