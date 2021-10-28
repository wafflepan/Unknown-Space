extends RigidBody2D

#A box that can be picked up, placed, and thrown by characters. Will eventually be able to hold stuff.

var carriedBy=null

var entityref

func _ready():
	entityref = get_parent()

func pickUp(who):
#	print("Calling carry RPC with ",who.name)
	rpc("carriedByActor",who.name)

func placeDown():
	rpc("droppedByActor")

func throw():
	pass

#master func _physics_process(delta):
#	if carriedBy:
#		rpc("carriedByActor")

remotesync func carriedByActor(who):
#	print("CarryObject picked up by ",who)
	carriedBy=entityref.get_node(who).get_node("Holding")
	self.mode = RigidBody2D.MODE_STATIC
	$CollisionShape2D.disabled=true
#	self.position = Vector2()
	get_parent().remove_child(self)
	carriedBy.add_child(self)
	$Tween.interpolate_property(self,"global_position",self.position,carriedBy.global_position,.2)
	$Tween.start()

remotesync func droppedByActor():
	carriedBy=null
	self.position = get_parent().global_position
	self.mode = RigidBody2D.MODE_CHARACTER
	$CollisionShape2D.disabled=false
	get_parent().remove_child(self)
	entityref.add_child(self)
