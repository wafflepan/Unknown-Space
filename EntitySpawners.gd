extends TileMap

func _ready():
	call_deferred("setupEntities")

func setupEntities():
	for tilecoord in get_used_cells():
#		print(tilecoord)
		var id = get_cell(tilecoord.x,tilecoord.y)
		var entityname = self.tile_set.tile_get_name(id)
		var newentity = load("res://"+str(entityname)+".tscn").instance()
		newentity.coordinates=tilecoord
		get_parent().get_node("Entities").add_child(newentity)
	self.visible=false
