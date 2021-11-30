extends Node2D

#Interprets player input and passes commands to an attached Actor.

var queuedclick = null #Click data used for checking the world with raycasts on-frame
var queuedrightclick = null

var drop_doubleclick_cooldown = 0

var placingItemMode=false

onready var actor = get_parent()

var inventoryUI
var menu #Right click menu

var activeInventoryItem = null #The current inventory item being manipulated. Used for action hotkeys, dropping/placing etc.

#func _ready():
#	$RightClickMenu.set_as_toplevel(true)

func setRightClickCanvasLayer(layer):
	menu = $RightClickMenu
	self.remove_child(menu)
	layer.add_child(menu)

func connectToInventoryUI(n):
	inventoryUI=n
	inventoryUI.connect("active_item_selected",self,"selectNewActiveItem")
	inventoryUI.connect("item_right_clicked",self,"onItemRightClicked")

func selectNewActiveItem(object):
	var entry = actor.inventory[object]
	activeInventoryItem=entry
	actor.showHeldItem(object)
	inventoryUI.setActiveItem(object)
#	activeInventoryItem.showItem()

func onItemRightClicked(item):
	rightClickMenu(item,Vector2())
	pass
	#TODO: Get options for context menu, 

func decrementTimers(d):
	pass
	if drop_doubleclick_cooldown > 0:
		drop_doubleclick_cooldown -= 1*d
#		print(drop_doubleclick_cooldown)
	else:
		drop_doubleclick_cooldown=0

func _unhandled_input(event):
	if get_tree().get_network_peer() and is_network_master():
	#	print("Unhandled Input")
		if event is InputEventMouseMotion: #Mousing over things isn't useful right now, but might be eventually.
			return
		if event is InputEventMouseButton and event.pressed and !event.is_echo():
			if event.button_index == BUTTON_LEFT:
				queuedclick = get_global_mouse_position()
				return
			elif event.button_index == BUTTON_RIGHT:
				queuedrightclick = get_global_mouse_position()
#				$RightClickMenu.rect_global_position=get_global_mouse_position()
		
		if Input.is_action_just_pressed("drop_item"):
			if (activeInventoryItem != null):
#				print("Active Item: ",activeInventoryItem)
				if drop_doubleclick_cooldown > 0:
					actor.placeDownItem(activeInventoryItem,self.global_position)
					inventoryUI.removeItem(activeInventoryItem)
					placingItemMode=false
					activeInventoryItem=null
					updateInventoryActive()
				elif drop_doubleclick_cooldown == 0 and placingItemMode==true: #Not a double-press, disable instead
					placingItemMode=false
					actor.hideInteractionRange()
				else:
					drop_doubleclick_cooldown=0.3
#					print("Placement mode")
					placingItemMode=true
					actor.displayInteractionRange()
					actor.update()
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
		desiredmovement = vec.normalized()

var desiredmovement = Vector2()

func commandActorDropDesignatedItem(item,location):
	actor.placeDownItem(activeInventoryItem,queuedclick)
	inventoryUI.removeItem(activeInventoryItem)
	placingItemMode=false
	activeInventoryItem=null
	updateInventoryActive()

func rightClickMenu(object,pos):
	menu.rect_position = Vector2(100,100)
	menu.popup(Rect2(Vector2(-300,-300),menu.rect_min_size))

func _process(delta):
	decrementTimers(delta)
	actor.setMovementDirection(desiredmovement)
	actor.queuedclick=queuedclick
	
	
	
	if queuedclick != null: #If a click occured last frame:
		if !placingItemMode:
			var space_state = get_world_2d().direct_space_state #Start up sequence for checking the space
			var clickresults = space_state.intersect_point(queuedclick)
			for item in clickresults:
				if item.collider.is_in_group("can_hold"):
					if (actor.isInteractableRange(item.collider.position)):
						var itemresult = item.collider.pickUp(self)
						if !itemresult:
							print("COULDNT GET ITEM INFO FROM PICKUP")
						else:
							var newinstance = load("res://CarriedObject.tscn").instance() #Click on item, pick it up
							actor.get_node("Holding").add_child(newinstance)
							actor.inventory[itemresult] = newinstance
							newinstance.pickUp(itemresult)
							inventoryUI.addItem(itemresult)
							activeInventoryItem=null
							updateInventoryActive()
						break #Only pick up one item from an overlapping pile. TODO: Shift-click to take all? Should prioritize lower-y-coord items (top of stack)
		else:
			if actor.isInteractableRange(queuedclick):
				commandActorDropDesignatedItem(activeInventoryItem,queuedclick)
		queuedclick=null
	if queuedrightclick != null: #If a click occured last frame:
		if !placingItemMode:
			var space_state = get_world_2d().direct_space_state #Start up sequence for checking the space
			var clickresults = space_state.intersect_point(queuedrightclick)
			for item in clickresults:
				if item.collider.is_in_group("can_hold"):
					if (actor.isInteractableRange(item.collider.position)):
						onItemRightClicked(item.collider)
						break #Only pick up one item from an overlapping pile.
		queuedrightclick=null

func updateInventoryActive():
	
	#After an item is placed down and removed from the actor's inventory list, get the next item
	if actor.inventory.size():
		selectNewActiveItem(actor.inventory.keys()[0])
	
#	print("After Update: ",activeInventoryItem)
