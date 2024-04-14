extends CharacterBody3D


const SPEED = 10
const ACCERLERATE = 0.02
const DEACCERLERATE = 0.01
const DASH_MULTIPLIER = 3
const JUMP_VELOCITY = 32
const MOUSE_SENSITIVITY = 0.03


var is_dashing = false
var can_flash_jump = false
var is_flash_jump = false
var is_stunned = false
var can_double_jump = true
var coyote_jump_helper = true

# pov helper
var is_pov_up = false


var final_speed: float = SPEED


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$CanvasLayer/ProgressBar.value = 900
	print(deg_to_rad(-80))
	print(deg_to_rad(80))
	print(transform.basis)
		

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENSITIVITY))
		$head.rotate_x(deg_to_rad(-event.relative.y * MOUSE_SENSITIVITY))
		$head.rotation.x = clampf($head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
		# if $head.rotation.y != 0 or $head.rotation.z != 0:
		# 	$head.rotation.y = 0
		# 	$head.rotation.z = 0


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * 8 * delta
		if $CoyoteTimer.time_left == 0 and coyote_jump_helper:
			$CoyoteTimer.start()
			coyote_jump_helper = false
	elif is_on_floor():
		can_double_jump = true
		coyote_jump_helper = true
		if $CrouchDashTimer.time_left > 0:
			is_flash_jump = true
		else:
			is_flash_jump = false

	# Handle Flash Jump.
	### Gotta check not flash jump first to prevent player from top speed
	if not is_flash_jump and not is_dashing:
		final_speed = lerpf(final_speed, SPEED, DEACCERLERATE)
	else:
		final_speed = lerpf(final_speed, SPEED*DASH_MULTIPLIER, ACCERLERATE)
	
	# Handel Dash
	if Input.is_action_just_pressed("dash"):
		$FlashJumpTimer.start()
		$SoundPlayer3.play("dash") # sfx
	elif Input.is_action_just_released("dash"):
		can_flash_jump = false
	if Input.is_action_pressed("dash"):
		if $CanvasLayer/ProgressBar.value > 0:
			final_speed = lerpf(final_speed, SPEED*DASH_MULTIPLIER, ACCERLERATE)
		else:
			final_speed = SPEED
		is_dashing = true
	else:
		is_dashing = false

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		# Stop coyote jump
		coyote_jump_helper = false

		if can_flash_jump == true:
			is_flash_jump = true
			$AnimationPlayer.play("flashjump")
	
	# Handle Coyote Jump.
	if Input.is_action_just_pressed("jump") and not is_on_floor() and $CoyoteTimer.time_left > 0:
		velocity.y = JUMP_VELOCITY
		$CoyoteTimer.stop()
		can_double_jump = true
	# Handle Double Jump.
	elif Input.is_action_just_pressed("jump") and not is_on_floor() and can_double_jump:
		velocity.y = JUMP_VELOCITY
		can_double_jump = false

	# Handle Crouch
	if Input.is_action_just_pressed("crouch"):
		$AcrobatPlayer.play("crouch")
		if can_flash_jump == true:
			is_flash_jump = true
			$AnimationPlayer.play("flashjump")
			$CrouchDashTimer.start()
	elif Input.is_action_just_released("crouch"):
		$AcrobatPlayer.play("uncrouch")

	# Godot Built-in XD
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if is_stunned:
		input_dir = Vector2.ZERO
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		# velocity.x = direction.x * final_speed
		velocity.x = move_toward(velocity.x, direction.x*final_speed, 0.5)
		velocity.z = move_toward(velocity.z, direction.z*final_speed, 0.5)
	else:
		pass
		velocity.x = move_toward(velocity.x, 0, 0.5)
		velocity.z = move_toward(velocity.z, 0, 0.5)

	float_up_and_down()
	move_and_slide()

	# others
	prevent_inifinite_fall()
	adjust_pov()
	$CanvasLayer/VelocityLabel.text = "Velocity: %s" % velocity.length()
	$CanvasLayer/IsFlashjumpLabel.text = "is_flash_jump: %s" % [is_flash_jump]


func float_up_and_down():
	var float_dir = Input.get_axis("float_down", "float_up")
	if float_dir:
		velocity.y = float_dir * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, 0.1)


func prevent_inifinite_fall():
	if position.y < -10:
		position = $"../SpawnPoint".position
		$head.rotation = Vector3.ZERO


func _on_dash_refill_timer_timeout():
	if is_dashing:
		$CanvasLayer/ProgressBar.value -= 10
	else:
		$CanvasLayer/ProgressBar.value += 10


func _on_flash_jump_timer_timeout():
	can_flash_jump = true


func adjust_pov():
	# weird way of doing me thing...
	var x_z_velocity: Vector2 = Vector2(velocity.x, velocity.z)
	# tween
	if x_z_velocity.length() >= 25 and not is_pov_up:
		is_pov_up = true
		var tween = create_tween()
		tween.tween_property($head/Camera3D, "fov", 120, 1)
	elif x_z_velocity.length() < 25 and is_pov_up:
		is_pov_up = false
		var tween = create_tween()
		tween.tween_property($head/Camera3D, "fov", 80, 1)


func push(power: int):
	var direction = (transform.basis * Vector3(0, 0, 1).normalized())
	if direction:
		velocity.x = direction.x * power
		velocity.z = direction.z * power


func _on_area_3d_body_entered(body):
	if body.is_in_group("wall"):
		print("Velocity: %s" % velocity)
		push(50)
		is_stunned = true
		$StunnedTimer.start()
		$SoundPlayer2.play("hit_wall")
	elif body.is_in_group("crushing_ceiling"):
		position = $"../SpawnPoint".position
		$head.rotation = Vector3.ZERO


func _on_stunned_timer_timeout():
	is_stunned = false


func _on_coyote_timer_timeout():
	pass
