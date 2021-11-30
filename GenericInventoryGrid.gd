extends Panel

#General-purpose grid that can have InventoryEntry moved between slots. Slots can be restricted to certain types, multiple slots to one item, etc.
#Click and drag functionality
#Automatically creating grids of any size/shape 

export var gridsize:Vector2 #How many slots, in width and height
export var force_square=true #Are the grid squares always square?
export var grid_margin:int = 5 #Pixel separation of grid squares

export var force_compress_slots = true #Decide whether the grid auto-sorts to the top left upon update.

var gridspaces = {} #Each grid space is the Vector2 center, and the contents (InventoryEntry)
#Maybe each dict needs an associated class entry that's a InventorySlot (to hold an Entry)

func _ready():
	recalculateGrid()
	placeDummyItems()

func placeDummyItems():
	var entry = load("InventoryEntry.tscn").instance()
	self.addItem(gridspaces.keys()[0],entry)
	pass #Test function to put some InventoryEntry items in the grid

func addItem(coord,entry):
	gridspaces[coord]=entry
	$Panels.get_node(str(coord)).add_child(entry)

func recalculateGrid():
	clearPanels()
	var area = self.rect_size
	for i in gridsize.x:
		for j in gridsize.y:
			var spacing = Vector2(area.x/gridsize.x,area.y/gridsize.y)
			var adjust = spacing/2 #Centering the squares
			gridspaces[Vector2(i,j)*spacing + adjust]=null
			makePanel(Vector2(i,j)*spacing + adjust,spacing)
	update()

func clearPanels():
	for child in $Panels.get_children():
		child.queue_free()

func makePanel(coord,size):
	var newpanel:Panel = Panel.new()
	var panelsize = size
	if force_square:
		panelsize = Vector2(1,1)*min(size.x,size.y)
	newpanel.rect_size = panelsize - Vector2(1,1)*grid_margin
	newpanel.rect_position = coord - panelsize/2 + Vector2(0.5,0.5)*grid_margin
	newpanel.name = str(coord)
	newpanel.connect("gui_input",self,"panel_input",[coord])
	newpanel.connect("mouse_entered",self,"panel_mouse_entered",[newpanel])
	newpanel.connect("mouse_exited",self,"panel_mouse_exited",[newpanel])
	$Panels.add_child(newpanel)

func panel_mouse_entered(panel):
	var tween = get_node("Tween")
	$Tween.interpolate_property(panel,"modulate",panel.modulate,Color(2,2,2),0.1,Tween.TRANS_SINE,Tween.EASE_IN)
	$Tween.start()

func panel_mouse_exited(panel):
	$Tween.interpolate_property(panel,"modulate",panel.modulate,Color(1,1,1),0.3,Tween.TRANS_SINE,Tween.EASE_IN)
	$Tween.start()

func panel_input(event,panel):
	pass
#	print("PANEL INPUT: ",panel,"  :  ",event)

func _on_GenericInventoryGrid_resized(): #Use this function to determine spacing and location of each grid space, and update accordingly
	call_deferred("recalculateGrid")

func _draw():
	for coordinate in gridspaces:
		draw_circle(coordinate,5,Color(1,1,1,0.4))
