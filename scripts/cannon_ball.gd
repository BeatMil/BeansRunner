extends RigidBody3D


func _ready():

	var direction =	($"../CharacterBody3D".global_position - position).normalized()
	print("direction: %s"%direction)
	apply_central_force(direction * 10000)
