extends Node2D

func _ready():
	$Tween.interpolate_property(self,"position",self.position,self.position+Vector2(0,-120),1.1,Tween.TRANS_QUINT,Tween.EASE_OUT)
	$Tween.interpolate_property(self,"modulate",self.modulate,Color(1,1,1,0),0.4,Tween.TRANS_LINEAR,Tween.EASE_IN,0.9-.4)
	$Tween.start()
	yield($Tween,"tween_all_completed")
	queue_free()
