extends TextureButton

#Component that can smoothly hide and show other UI elements via dropping them offscreen with tween and anchors

export var DEFAULT_ANCHOR_TOP:float = 0.5 #Set to zero for fixed-size elements that don't use anchors

var isHidden=false

var texture_down = preload("res://Sprites/UI/ui_chevron_down.png")
var texture_up = preload("res://Sprites/UI/ui_chevron_up.png")

func _ready():
	DEFAULT_ANCHOR_TOP=get_parent().anchor_top
	if get_parent().anchor_bottom == get_parent().anchor_top:
		DEFAULT_ANCHOR_TOP=0

func _on_PanelHideButton_pressed(): #Shows and hides the UI frame with a smooth animation
	self.disabled=true
	if DEFAULT_ANCHOR_TOP == 0:#Different settings for fixed-size UI elements
		if !isHidden:
			self.texture_normal = texture_up
			$Tween.interpolate_property(get_parent(),"rect_position",get_parent().rect_position,get_parent().rect_position + Vector2(0,get_parent().rect_size.y),.4,Tween.TRANS_EXPO,Tween.EASE_OUT)
			$Tween.start()
			isHidden=true
		else:
			self.texture_normal = texture_down
			$Tween.interpolate_property(get_parent(),"rect_position",get_parent().rect_position,get_parent().rect_position - Vector2(0,get_parent().rect_size.y),.4,Tween.TRANS_EXPO,Tween.EASE_OUT)
			$Tween.start()
			isHidden=false 
	else:
		if !isHidden:
			self.texture_normal = texture_up
			$Tween.interpolate_property(get_parent(),"anchor_top",DEFAULT_ANCHOR_TOP,1,.4,Tween.TRANS_BACK,Tween.EASE_IN)
			$Tween.start()
			isHidden=true
		else:
			self.texture_normal = texture_down
			$Tween.interpolate_property(get_parent(),"anchor_top",1,DEFAULT_ANCHOR_TOP,.4,Tween.TRANS_BACK,Tween.EASE_OUT)
			$Tween.start()
			isHidden=false
	yield($Tween,"tween_all_completed")
	self.disabled=false
