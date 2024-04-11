extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_timer_timeout():
	$MovingFloor.apply_central_force(Vector3(100,  0 ,0))


func _on_area_3d_body_entered(body):
	if body.name == "bean":
		body.apply_force(Vector3(0,500,0))
		body.apply_torque(Vector3(100,200,0))
		body.name = "bob"
