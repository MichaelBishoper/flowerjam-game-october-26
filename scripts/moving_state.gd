class_name MovingState extends PlayerState	

@onready var animated_sprite_2d: AnimatedSprite2D = $"../../AnimatedSprite2D"
@onready var camera_2d: Camera = $"../../../Camera2D"

# SFX Players
@onready var press_right: AudioStreamPlayer2D = $"../../PressRight"
@onready var press_left: AudioStreamPlayer2D = $"../../PressLeft"
@onready var press_down: AudioStreamPlayer2D = $"../../PressDown"
@onready var press_up: AudioStreamPlayer2D = $"../../PressUp"
@onready var moving: AudioStreamPlayer2D = $"../../Moving"

var sfx_array: Array[AudioStreamPlayer2D]
var collision: KinematicCollision2D

func enter(previous_state_path: String, data := {}) -> void:
	# Set camera to follow player
	camera_2d.set_target(player)
	
	#print("Previous State: ", previous_state_path)
	#print("Current State: Moving")
	
	# Store the audio sfx to an array
	sfx_array = [press_down, press_left, press_right, press_up]
	
	animated_sprite_2d.show()
	animated_sprite_2d.play("temporary_secretary")

func physics_update(_delta: float) -> void:
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var target := Vector2(input_dir.x * player.max_speed_x, input_dir.y * player.max_speed_y)
	
	print(input_dir)
	
	if input_dir != Vector2.ZERO:
		if not moving.playing:
			moving.play()
		player.velocity.x = move_toward(player.velocity.x, target.x, player.acceleration_x * _delta)
		player.velocity.y = move_toward(player.velocity.y, target.y, player.acceleration_y * _delta)
	else:
		if moving.playing:
			moving.stop()
		player.velocity.x = move_toward(player.velocity.x, 0.0, player.friction_x * _delta)
		player.velocity.y = move_toward(player.velocity.y, 0.0, player.friction_y * _delta)
	
	if collision:
		if player.velocity.x > 200.0:
			animated_sprite_2d.play("bounce")
		if player.velocity.x < -200.0:
			animated_sprite_2d.play("bounce")
	
	# For Animations Later!!!
	var direction_name := _infer_direction(input_dir)
	match direction_name:
		"Left":
			pass
		"Right":
			pass
		
	
	var motion = player.velocity * _delta
	
	collision = player.move_and_collide(motion)
	
	if collision:
		# If player velocity x negative then go right
		var normal = collision.get_normal()
		var bounce_factor = 0.8
		player.velocity = player.velocity.bounce(normal) * bounce_factor
		
	
	# State Changes
	if player.velocity == Vector2.ZERO:
		finished.emit(IDLE)

func handle_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("select"):
		finished.emit(SELECTING)
	
	# FORGIVE ME FOR MY CODING SINS PLEASE GOD
	if (Input.is_action_just_pressed("move_right")):
		animated_sprite_2d.flip_h = true
	if (Input.is_action_just_pressed("move_left")):
		animated_sprite_2d.flip_h = false
	
	# If any audio is playing wait for it to end
	for s in sfx_array:
		if s.playing:
			return
			
	# Playing Audio
	if (Input.is_action_just_pressed("move_right")):
		press_right.play()
	if (Input.is_action_just_pressed("move_left")):
		press_left.play()
	if (Input.is_action_just_pressed("move_down")):
		press_down.play()
	if (Input.is_action_just_pressed("move_up")):
		press_up.play()

func _infer_direction(_direction: Vector2) -> String:
	if _direction == Vector2.UP:
		return "Up"
	elif _direction == Vector2.DOWN:
		return "Down"
	elif _direction == Vector2.LEFT:
		return "Left"
	elif _direction == Vector2.RIGHT:
		return "Right"
	elif _direction.snapped(Vector2(0.01, 0.01)) == Vector2(0.71, 0.71):
		return "Down Right"
	elif _direction.snapped(Vector2(0.01, 0.01)) == Vector2(-0.71, 0.71):
		return "Down Left"
	elif _direction.snapped(Vector2(0.01, 0.01)) == Vector2(0.71, -0.71):
		return "Up Right"
	elif _direction.snapped(Vector2(0.01, 0.01)) == Vector2(-0.71, -0.71):
		return "Up Left"
	return "Down"

func exit() -> void:
	pass
