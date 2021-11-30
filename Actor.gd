extends KinematicBody2D

var velocity = 0
var velocitymax = 300
var movedirection = Vector2()

var deccel = 40
var accel = 10

var inventory ={} setget inventoryUpdated

#func _ready():
#	if !is_network_master():
##		set_process_input(false)
#		set_physics_process(false)

func setDisplayName(value):
	$ActorName.text=value

func enableGrabMode(): #Pick up small items, or start dragging large ones.
	pass

func disableGrabMode():
	pass
	

func inventoryUpdated(inv):
	print("Inventory List: ",inventory)

var held = []
var placingItemMode=false

var queuedclick = null #Queued mouse input event for evaluation next physics frame, to check for clickable items.
var queuedmousepos = null

remote func setPosition(loc):
	self.global_position=loc

func dropAllItems():
	for item in inventory:
		placeDownItem(item,self.position)

func setMovementDirection(vec):
	movedirection=vec

func _physics_process(delta):
#	print(inventory)
	queuedmousepos = get_global_mouse_position()
#	decrementTimers(delta)
	if get_tree().get_network_peer() and is_network_master(): #Only the master verion of the node needs to perform collisions and stuff
		var vector = movedirection
#			vector = Vector2(1,0).rotated(1)
		if vector == Vector2():
			velocity = clamp(velocity-deccel,0,velocitymax)
		else:
			velocity = clamp(velocity+accel,0,velocitymax)
		var results = move_and_slide((velocity*vector),Vector2(),false,6,1,false)
		
		for slide_idx in get_slide_count():
#				print(get_slide_collision(slide_idx).collider.name)
			var collision = get_slide_collision(slide_idx)
			if collision.collider.is_in_group("pushable"):
				collision.collider.apply_central_impulse(-collision.normal*velocity/100)
#			print("New Position of master actor: ",self.global_position)
		rpc_unreliable("setPosition",self.global_position)
		
		
	update()

func placeDownItem(obj,loc):
	obj.placeDown(loc)
	inventory.erase(obj.object)
	inventoryUpdated(inventory)
	placingItemMode=false
	hideInteractionRange()
	update()

func showHeldItem(obj):
	for entry in inventory:
		if entry == obj:
			inventory[obj].showItem()
		else:
			inventory[entry].hideItemOnArrival()

func pickUpItem(obj):
	pass
	inventory.append(obj)

func generateAtlasImage(obj): #Turn a single sprite frame into an atlas image
	if obj == null:
		return null
	var sprite:Sprite = obj.object.getSprite()
	var atlas = AtlasTexture.new()
	atlas.atlas=sprite.texture
	
	var imagesize = sprite.texture.get_size()
	var framesize = Vector2(imagesize.x/sprite.hframes,imagesize.y/sprite.vframes)
	var offset = Vector2(sprite.frame%sprite.hframes,int(sprite.frame/sprite.hframes))
	atlas.region = Rect2(offset.x*framesize.x,offset.y*framesize.y,framesize.x,framesize.y)
#	print("Generated Atlas Texture at ",Rect2(offset.x,offset.y,framesize.x,framesize.y))
	return atlas


var isInteractionRangeShown = false

func displayInteractionRange():
	isInteractionRangeShown=true

func hideInteractionRange():
	isInteractionRangeShown=false

func isInteractableRange(point:Vector2):
	return Geometry.is_point_in_circle(point,self.position,$InteractionRange/CollisionShape2D.shape.radius)

func _draw():
	if isInteractionRangeShown:
		draw_circle(Vector2(),$InteractionRange/CollisionShape2D.shape.radius,Color(0,0.6,0.6,0.3))
	if placingItemMode:
		pass
		var itemsprite = generateAtlasImage(inventory[0])
		if itemsprite:
			draw_texture(itemsprite,to_local(queuedmousepos-itemsprite.get_size()/2),Color(1,1,1,0.7))
		#Draw a transparent sprite at the location of the potential placement
		#TODO: Coloration to indicate valid placement, maybe with a blue color to indicate a snapping method that connects to a port or something, red for no, green for yes
