extends Sprite

#Actor placeholder for a carried (visible) object

#Mostly exists to be placed as a child of the Actor and move smoothly
#Swaps in and out with its parent representation as needed (when placed into world)

var object = null #The object that this item represents
var movementLockout = false

func pickUp(obj): #Tween from object position to final location
	movementLockout=true
	var startpoint = get_parent().to_local(obj.global_position)
	var endpoint = Vector2()
	object=obj
	var sp = obj.getSprite()
	self.texture = sp.texture
	self.hframes = sp.hframes
	self.vframes=sp.vframes
	self.frame=sp.frame
	self.position = startpoint
	object.disableObject()
	$Tween.interpolate_property(self,"position",startpoint,endpoint,0.2,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
	$Tween.interpolate_property(self,"scale",Vector2(1,1),Vector2(1,1)*0.7,0.2,Tween.TRANS_EXPO,Tween.EASE_IN)
	$Tween.start()
	yield($Tween,"tween_all_completed")
	movementLockout=false

func placeDown(pos):
	
	$Tween.interpolate_property(self,"position",Vector2(),get_parent().to_local(pos),0.2,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
	$Tween.interpolate_property(self,"scale",self.scale,Vector2(1,1),0.2,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
	$Tween.start()
	movementLockout=true
	yield($Tween,"tween_all_completed")
	object.position = pos
	object.enableObject()
	self.queue_free()

func showItem():
	self.visible=true

func hideItem():
	self.visible=false

func hideItemOnArrival():
	if movementLockout:
		yield($Tween,"tween_all_completed")
	hideItem()
