extends KinematicBody2D

var velocity = 0
var velocitymax = 300
var movedirection = Vector2()

var deccel = 40
var accel = 10

var inventory = {}
var status = {}

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
	

func _unhandled_input(event):
	if get_tree().get_network_peer() and is_network_master():
	#	print("Unhandled Input")
		if event is InputEventMouseMotion: #Mousing over things isn't useful right now, but might be eventually.
			return
		if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed and !event.is_echo():
			queuedclick = get_global_mouse_position()
			return
		
		if Input.is_action_pressed("drop_item") and $Holding.get_child_count() > 0:
			$Holding.get_child(0).placeDown() #TODO: doubleclick behavior here to allow for 'P to place/throw, doubletap P to drop at feet'
			return
		
		var vec = Vector2()
		if Input.is_action_pressed("move_up"):
			vec += Vector2(0,-1)
			get_tree().set_input_as_handled()
		if Input.is_action_pressed("move_down"):
			vec += Vector2(0,1)
			get_tree().set_input_as_handled()
		if Input.is_action_pressed("move_left"):
			vec += Vector2(-1,0)
			get_tree().set_input_as_handled()
		if Input.is_action_pressed("move_right"):
			vec += Vector2(1,0)
			get_tree().set_input_as_handled()
#		print(vec)
		movedirection = vec.normalized()

var queuedclick = null #Queued mouse input event for evaluation next physics frame, to check for clickable items.

remote func setPosition(loc):
	self.global_position=loc

func dropAllItems():
	for item in $Holding.get_children():
		item.placeDown()

func _physics_process(delta):
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
			
			
			if queuedclick != null:
				var space_state = get_world_2d().direct_space_state
				var clickresults = space_state.intersect_point(queuedclick)
				for item in clickresults:
					if item.collider.is_in_group("can_hold") and (item.collider in $InteractionRange.get_overlapping_bodies()):
						item.collider.pickUp(self)
				queuedclick=null
			
	#		elif get_tree().get_network_peer() and !is_network_master():
	#			print(self.name," tried to input commands to someone else's puppet on client #",multiplayer.get_network_unique_id())

var isInteractionRangeShown = false

func displayInteractionRange():
	isInteractionRangeShown=true

func hideInteractionRange():
	isInteractionRangeShown=false

func isInteractableRange(point:Vector2):
	return Geometry.is_point_in_circle(point,self.position,$InteractionRange/CollisionShape2D.shape.radius)

func _draw():
	if isInteractionRangeShown:
		draw_circle(Vector2(),$InteractionRange/CollisionShape2D.shape.radius,Color(0,0.7,0.7,0.4))
