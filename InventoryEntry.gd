extends CenterContainer

#Holds information about an inventory item that can be used to relocate it (click and drag), select it, etc.

var object = null #Reference to the object it represents. Will be used to obtain sizing info, context menus, etc.

func setup(obj,image):
	object=obj
	$TextureButton.texture_normal=image #Use atlas image to avoid spritesheet fuckery
