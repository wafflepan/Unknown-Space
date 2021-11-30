extends Control


var slots = {} #Dict that holds the Vec2 coordinates on the inventory grid and associated item. Coordinates:Entry
var items= {} #These are two separate categories because one item can take multiple slots. ObjectID:AssociatedEntry

#Inventory grid for things the player is carrying. Visually represent objects of various sizes in grid spaces, 
#allow clicking and dragging out to enter placement mode, select items, context menus when right clicked.

var activeEntry = null

func _ready():
	setGridProperties()
	refreshGrid()

func refreshGrid():
	pass
	for item in $Panel/MarginContainer/GridContainer.get_children():
		item.free()
	for item in items:
		addItem(item)

func addItem(object):
	var entry = load("res://InventoryEntry.tscn").instance()
	entry.setup(object,generateAtlasImage(object))
	items[object]=entry
	$Panel/MarginContainer/GridContainer.add_child(entry)
	entry.get_node("TextureButton").connect("gui_input",self,"inventoryEntryButtonPressed",[entry])

func setGridProperties():
	var rect = $Panel/MarginContainer/GridContainer.rect_size
	var entrysize = Vector2(50,50)
	var gridwidth:float = $Panel/MarginContainer/GridContainer.columns
	$Panel/MarginContainer/GridContainer.set("custom_constant/hseparation",((rect.x - entrysize.x*gridwidth) / gridwidth))
#	print("Set Horizontal Grid Spacing to ",(rect.x - entrysize.x*gridwidth) / gridwidth)
	$Panel/MarginContainer/GridContainer.set("custom_constant/hseparation",200)

func setActiveItem(it):
	for entry in items:
		items[entry].modulate=Color(1,1,1)
	if it in items:
		items[it].modulate=Color(0.6,1,0.6)
		activeEntry = items[it]

signal active_item_selected
signal item_right_clicked
signal active_item_clicked

func inventoryEntryButtonPressed(event,entry):
	if event is InputEventMouseButton and event.is_pressed() and !event.is_echo():
#	print("Inventory Entry clicked: ",entry.object.name)
		if event.button_index == BUTTON_LEFT:
			if activeEntry == entry:
				emit_signal("active_item_clicked",entry.object) #Clicking an item that's already active should trigger its toplevel/first interaction (open/close box, turn on flashlight, etc)
			else:
				setActiveItem(entry.object)
				emit_signal("active_item_selected",entry.object)
		elif event.button_index == BUTTON_RIGHT:
			itemRightClicked(entry)

func itemRightClicked(entry):
	emit_signal("item_right_clicked",entry.object)

func removeItem(en):
	if !items.has(en.object):
		print("Tried to remove nonexistant item.")
		return
	var entry=items[en.object]
	for slot in slots:
		if slots[slot] == entry:
			slots[slot]=null
	items.erase(en.object)
	entry.free()
#TODO: Make this a custom implementation of the gridContainer that emphasizes defining and reserving grid squares.

func generateAtlasImage(obj): #Turn a single sprite frame into an atlas image
	var sprite:Sprite = obj.getSprite()
	var atlas = AtlasTexture.new()
	atlas.atlas=sprite.texture
	
	var imagesize = sprite.texture.get_size()
	var framesize = Vector2(imagesize.x/sprite.hframes,imagesize.y/sprite.vframes)
	var offset = Vector2(sprite.frame%sprite.hframes,int(sprite.frame/sprite.hframes))
	atlas.region = Rect2(offset.x*framesize.x,offset.y*framesize.y,framesize.x,framesize.y)
#	print("Generated Atlas Texture at ",Rect2(offset.x,offset.y,framesize.x,framesize.y))
	return atlas
