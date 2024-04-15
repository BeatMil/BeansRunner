extends Node3D


func _ready():
	randomize()
	$Timer.wait_time = randf_range(0, 3)
	$Timer.start()


func _on_body_entered(body):
	if body.is_in_group("player"):
		body.get_hit_by_slime()


func _on_timer_timeout():
	$AnimationPlayer.play("moving")
