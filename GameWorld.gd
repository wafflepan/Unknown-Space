extends Node2D

var localdata = {"Username":"TestPlayer"}

var primaryplayer

onready var primarygrid = $YSort/WallTiles

func _ready():
	var newplayer = createNewPlayer(NetworkManager.getData())
	primaryplayer=newplayer #Set main character
	var camera = $Camera2D
	remove_child(camera)
	primaryplayer.add_child(camera)
	newplayer.set_network_master(get_tree().get_network_unique_id())

func createNewPlayer(data):
	if data.size():
		localdata = data
	var newplayer= load("res://Actor.tscn").instance()
	newplayer.name = localdata["Username"]
	$YSort/Entities.add_child(newplayer)
	return newplayer

func getGrid():
	return primarygrid
