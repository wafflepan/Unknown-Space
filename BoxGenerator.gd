extends "res://TileEntity.gd"

#Appearifies objects

export var template:PackedScene #Object to appearify

var currentlyActive=false

signal request_spawn_object


func _ready():
	self.connect("request_spawn_object",get_parent().get_parent().get_parent(),"on_object_spawn_request")

func checkPedestal():
	pass
	var results = $CheckArea.get_overlapping_bodies()
	return results.size()

func activate():
	$DissolveSprite.material.set_shader_param("burn_position",1)
	$DissolveSprite.visible=true
	currentlyActive=true
	
	$AnimationPlayer.play("Fadein")
	yield($AnimationPlayer,"animation_finished")
	createObject(template)
	$DissolveSprite.visible=false

func createObject(obj):
	emit_signal('request_spawn_object',obj,$DissolveSprite.global_position)

#func _process(delta):
#	print($DissolveSprite.material.get_shader_param("burn_position"))

func _on_Timer_timeout():
	if !checkPedestal():
		activate()
