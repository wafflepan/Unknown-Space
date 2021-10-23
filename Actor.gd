extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var velocity = 0
var velocitymax = 300

var deccel = 40
var accel = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	$ActorName.text = self.name

func setName(value):
	$ActorName.text=value

func getInput():
	var vec = Vector2()
	if Input.is_action_pressed("move_up"):
		vec += Vector2(0,-1)
	if Input.is_action_pressed("move_down"):
		vec += Vector2(0,1)
	if Input.is_action_pressed("move_left"):
		vec += Vector2(-1,0)
	if Input.is_action_pressed("move_right"):
		vec += Vector2(1,0)
	return vec.normalized()

remote func setPosition(loc):
	self.global_position=loc

func _physics_process(delta):
		if get_tree().get_network_peer() and is_network_master():
			var vector = getInput()
			if vector == Vector2():
				velocity = clamp(velocity-deccel,0,velocitymax)
			else:
				velocity = clamp(velocity+accel,0,velocitymax)
			var results = move_and_slide((velocity*vector))
			rpc_unreliable("setPosition",self.global_position)
