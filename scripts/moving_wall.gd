extends StaticBody3D
@export var time_before_start: float

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.wait_time = time_before_start
	$Timer.start()


func _on_timer_timeout():
	$AnimationPlayer.play("moving")
