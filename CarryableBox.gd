extends KinematicBody2D

#A box that can be picked up, placed, and thrown by characters. Will eventually be able to hold stuff.

var carriedBy=null

var entityref

var size = Vector2(2,2) #For now, sizes must be square. Eventually, create some kind of bitmask method for weird shapes.

#var setpos = null
#
#func _integrate_forces(state):
#	if setpos:
#		state.transform.origin=setpos
#		setpos=null

func disableObject():
	visible=false
	$CollisionShape2D.disabled=true

func enableObject():
	visible=true
	$CollisionShape2D.disabled=false

func _ready():
	entityref = get_parent()

func getSprite():
	return $Sprite

func pickUp(who):
	if carriedBy==null:
#	print("Calling carry RPC with ",who.name)
#		rpc("carriedByActor",who)
		return self
	else:
		print("Already being carried! Wtf?")
		

func placeDown():
	if carriedBy != null:
		rpc("droppedByActor")

func throw(): #If the target for placement is out of reach, throw it instead
	pass

#func _physics_process(delta): #TODO: Change this to making the item hidden and intangible, with a fake 'held item sprite' on the actor to be carried around more tightly.
#	if carriedBy != null:
#		self.transform = carriedBy.global_transform

remotesync func carriedByActor(who):
#	print("CarryObject picked up by ",who)
	carriedBy=who
	carriedBy.held.append(self)
	z_index+=1
#	self.mode = RigidBody2D.MODE_STATIC
	$CollisionShape2D.disabled=true
#	self.position = Vector2()
#	get_parent().remove_child(self)
#	carriedBy.add_child(self)
#	$Tween.interpolate_property(self,"global_position",self.position,carriedBy.global_position,.2)
#	$Tween.start()

remotesync func droppedByActor():
	carriedBy.held.erase(self)
	carriedBy=null
	z_index-=1
#	self.position = get_parent().global_position
#	self.mode = RigidBody2D.MODE_CHARACTER
	$CollisionShape2D.disabled=false
#	get_parent().remove_child(self)
#	entityref.add_child(self)
