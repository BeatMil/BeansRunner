extends Node3D


func _ready():
	var shift_key = InputMap.action_get_events("dash")
	$DashLabel3D.text = "Hold %s to dash" % shift_key[0].as_text()

	var crouch_key = InputMap.action_get_events("crouch")
	$CrouchLabel3D.text = "Hold %s to crouch" % crouch_key[0].as_text()

	var jump_key = InputMap.action_get_events("jump")
	$JumpLabel3D.text = "Press %s to jump" % jump_key[0].as_text()

	var double_jump_key = InputMap.action_get_events("jump")
	$DoubleJumpLabel3D.text = "Press %s again to double jump!" % double_jump_key[0].as_text()
