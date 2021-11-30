extends RigidBody2D

func _ready():
	$Sprite.frame = randi()%14

func _physics_process(delta):
	if !sleeping and is_network_master():
		rpc_unreliable("update_physics",get_global_transform(),linear_velocity,angular_velocity)

remote func update_physics(tf,linvel,angvel):
	self.transform = tf
	linear_velocity=linvel
	angular_velocity=angvel

func _on_Crate_sleeping_state_changed():
	if is_network_master():
		rpc_unreliable("update_physics",get_global_transform(),linear_velocity,angular_velocity)
