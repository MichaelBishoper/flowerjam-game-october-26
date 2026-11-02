class_name MovingState extends PlayerState	

@onready var animated_sprite_2d: AnimatedSprite2D = $"../../AnimatedSprite2D"
@onready var camera_2d: Camera = $"../../../Camera2D"
@onready var ray: RayCast2D = $"../../Ray"
@onready var h_slider: HSlider = $"../../UI/HSlider"

# SFX Players
@onready var press_right: AudioStreamPlayer2D = $"../../PressRight"
@onready var press_left: AudioStreamPlayer2D = $"../../PressLeft"
@onready var press_down: AudioStreamPlayer2D = $"../../PressDown"
@onready var press_up: AudioStreamPlayer2D = $"../../PressUp"
@onready var moving: AudioStreamPlayer2D = $"../../Moving"
@onready var bump_light: AudioStreamPlayer = $"../../BumpLight"
@onready var bump_heavy: AudioStreamPlayer = $"../../BumpHeavy"
var sfx_array: Array[AudioStreamPlayer2D]

var collision: KinematicCollision2D
var flight_bar: float
var is_flying := false
signal flight_bar_updated(flight_left: float)

var is_just_landed: bool = false
var was_landed: bool = false

func enter(previous_state_path: String, data := {}) -> void:
	# Set camera to follow player
	camera_2d.set_target(player)
	
	if previous_state_path == SELECTING or previous_state_path == HAUnTING or previous_state_path == IDLE:
		flight_bar = data.get("flight_bar")
		flight_bar_updated.emit(flight_bar)
	else: flight_bar = player.flight_max_time
	
	#print("Previous State: ", previous_state_path)
	#print("Current State: Moving")
	
	# Store the audio sfx to an array
	sfx_array = [press_down, press_left, press_right, press_up]
	
	animated_sprite_2d.show()
	animated_sprite_2d.play("bob")
	# Conect animatedsprite2d's signal to local function
	animated_sprite_2d.animation_finished.connect(_on_animation_finished)
	
	# Connect local signal to local function
	flight_bar_updated.connect(_on_flight_bar_updated)
	# Define the slider's lower and higher bounds
	h_slider.max_value = player.flight_max_time
	h_slider.min_value = 0.0
	
func _on_flight_bar_updated(flight_left: float) -> void:
	h_slider.value = flight_left

func physics_update(_delta: float) -> void:
	if not Input.is_action_pressed("move_down"):
		# For the downwards raycast to update the result to the current frame's
		ray.force_raycast_update()
		# Raycast/Hover Logic
		if ray.is_colliding():
			var ground_y := ray.get_collision_point().y
			# NOTE: Godot uses negative y coordiantes to mean up, so the lower point has the greater y value!!!!
			var target_y := ground_y - player.hover_height
			var current_y := player.global_position.y
			
			# Pull up the player if it is below the target_y
			if current_y > target_y:
				player.global_position.y = move_toward(current_y, target_y, player.hover_snap)
				if player.velocity.y > 0.0:
					player.velocity.y = 0.0
		
	# Movement Logic
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var target := Vector2(input_dir.x * player.max_speed_x, input_dir.y * player.max_speed_y)
	
	# DEBUG PRINTS
	print("Player Velo: ", player.velocity.y)
	#print("Target Velo: ", target.y)
	
	# Horizontal Movement
	if input_dir != Vector2.ZERO:
		player.velocity.x = move_toward(player.velocity.x, target.x, player.acceleration_x * _delta)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0.0, player.friction_x * _delta)
	
	# Vertical Movement
	# Flight
	var flight_pressed := Input.is_action_pressed("move_up")
	is_flying = flight_pressed and flight_bar > 0.0
	
	if is_flying:
		# Audio logic
		if not moving.playing:
			moving.play()
		flight_bar -= _delta
		player.velocity.y = move_toward(player.velocity.y, player.flight_acceleration, 2000.0 * _delta)
	else:
		if moving.playing:
			moving.stop()
		# Falling input
		if Input.is_action_just_pressed("move_down"):
			player.velocity.y = move_toward(player.velocity.y, target.y, player.acceleration_y * _delta)
		else:
			# Apply gravity
			player.velocity.y += player.gravity * _delta
			player.velocity.y = minf(player.velocity.y, player.max_fall_speed) 
		
	# Collisions and their animations and audio
	if collision:
		if player.velocity.x * 1.3 > player.velocity.y:
			# PLAYER BUMPS RIGHT
			if player.velocity.x > 200.0:
				if not bump_heavy.playing: 
					bump_heavy.play()
				animated_sprite_2d.play("bounce")
			# PLAYER BUMPS LEFT
			if player.velocity.x < -200.0:
				if not bump_heavy.playing: 
					bump_heavy.play()
				animated_sprite_2d.play("bounce")
		elif player.velocity.x < player.velocity.y:
			# PLAYER BUMPS UP
			if player.velocity.y > 550.0:
				if not bump_heavy.playing: 
					bump_heavy.play()
				animated_sprite_2d.play("bounce_up")
			if player.velocity.y < -550.0:
				if not bump_heavy.playing:
					bump_heavy.play()
				print("Bounce Down")
	else:
		# PLAYER LANDS HOVERING
		if player.velocity.y < 550.0 and is_just_landed:
			#TODO: Change this to a light hover sound
			if not bump_heavy.playing: 
				bump_heavy.play()
			# DEBUG: For Velocity
			#print(player.velocity.y)
			#print("Bounce Down")
	
	var motion = player.velocity * _delta
	collision = player.move_and_collide(motion)
	
	if collision:
		# If player velocity x negative then go right
		var normal = collision.get_normal()
		var bounce_factor = 0.8
		player.velocity = player.velocity.bounce(normal) * bounce_factor
	
	# Flight Refill Logic
	if ray.is_colliding() and not is_flying:
		var ground_y := ray.get_collision_point().y
		var dist_to_ground := ground_y - player.global_position.y
		# NOTE: Change 4.0 to adjust the tolerance
		# When refill happens
		if dist_to_ground <= player.hover_height + 4.0: 
			is_just_landed = not was_landed
			was_landed = true
			flight_bar = minf(flight_bar + player.flight_refill_time * _delta, player.flight_max_time)
		else:
			is_just_landed = false
			was_landed = false	
	else:
		was_landed = false
		
	# Update flight bar
	flight_bar_updated.emit(flight_bar)
	
	# State Changes
	if player.velocity == Vector2.ZERO:
		finished.emit(IDLE)

func handle_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("select"):
		finished.emit(SELECTING, { "flight_bar" : flight_bar })
	
	# FORGIVE ME FOR MY CODING SINS PLEASE GOD
	# Flipping logic plays first so the audio await code does not block it
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
	
func _on_animation_finished() -> void:
	if animated_sprite_2d.animation == "bounce":
		animated_sprite_2d.play("bob")
