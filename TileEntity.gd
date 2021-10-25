extends Node2D

export (Vector2) var coordinates = null

var isOpening=false
var isClosing=false

func _ready():
#	setClosed()
	call_deferred("updateTileLocation",coordinates)
#	call_deferred("close")

#TODO: have stuff in here to detect if adjacent tiles are floor, wall, or void

#remotesync func setClosed(): #Force door closed without animation or sound
#	if $AnimationPlayer.current_animation_positio
#	$AnimationPlayer.seek(0,true)

func updateTileLocation(coords):
	self.position = getTileGrid().map_to_world(coords) + Vector2(32,32)

func getTileGrid():
	return get_parent().get_parent().get_parent().getGrid()

func coordinatesUpdated(coord):
	updateTileLocation(coord)

remotesync func open():
	if isOpening:
		return
	isOpening=true
	$AnimationPlayer.stop()
	$AnimationPlayer.play("open")
	$CloseTimer.start()
	$AudioStreamPlayer.play()
	yield($AnimationPlayer,"animation_finished")
	isOpening=false

remotesync func close():
	if isClosing:
		return
	isClosing=true
	$AnimationPlayer.play_backwards("open")
	$AudioStreamPlayer.play()
	yield($AnimationPlayer,"animation_finished")
	isClosing=false


func _on_MotionSensor_body_entered(body):
	if body.is_in_group("players"):
		rpc("open")


func _on_CloseTimer_timeout():
	rpc("close")
