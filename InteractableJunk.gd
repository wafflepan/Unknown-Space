extends "res://CarryableBox.gd"

#Carryable object that can be right clicked for an interaction menu

func _ready():
	$Sprite.frame = randi()%($Sprite.hframes*$Sprite.vframes)
	._ready()
