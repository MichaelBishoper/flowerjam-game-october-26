class_name MovingState extends PlayerState	

@onready var animated_sprite_2d: AnimatedSprite2D = $"../../AnimatedSprite2D"
@onready var camera_2d: Camera = $"../../../Camera2D"
@onready var h_slider: HSlider = $"../../UI/HSlider"
@onready var moving: AudioStreamPlayer2D = $"../../Moving"
@onready var bump_light: AudioStreamPlayer = $"../../BumpLight"
@onready var bump_heavy: AudioStreamPlayer = $"../../BumpHeavy"

var collision: KinematicCollision2D = null
var flight_bar: float
var is_flying := false
signal flight_bar_updated(flight_left: float)

# --- BUILT INS --- #
func enter(previous_state_path: String, data := {}) -> void:
	# Set camera to follow player
	camera_2d.set_target(player)
	
	if previous_state_path == SELECTING or previous_state_path == HAUnTING or previous_state_path == IDLE:
		flight_bar = data.get("flight_bar")
		flight_bar_updated.emit(flight_bar)
	else: flight_bar = player.flight_max_time
	
	#print("Previous State: ", previous_state_path)
	#print("Current State: Moving")
	
	animated_sprite_2d.show()
	animated_sprite_2d.play("bob")
	# Conect animatedsprite2d's signal to local function
	animated_sprite_2d.animation_finished.connect(_on_animation_finished)
	
	# Connect local signal to local function
	flight_bar_updated.connect(_on_flight_bar_updated)
	# Define the slider's lower and higher bounds
	h_slider.max_value = player.flight_max_time
	h_slider.min_value = 0.0
	
func physics_update(_delta: float) -> void:
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var target := Vector2(input_dir.x * player.max_speed_x, input_dir.y * player.max_speed_y)

	# --- HORIZONTAL MOVEMENT --- #
	if input_dir != Vector2.ZERO:
		player.velocity.x = move_toward(player.velocity.x, target.x, player.acceleration_x * _delta)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0.0, player.friction_x * _delta)
	
	# --- FLYING --- #
	var flight_pressed := Input.is_action_pressed("move_up")
	is_flying = flight_pressed and flight_bar > 0.0
	
	if is_flying:
		if not moving.playing:
			moving.play()
		flight_bar -= _delta
		player.velocity.y = move_toward(player.velocity.y, player.flight_acceleration, player.acceleration_y * _delta)
	else:
		if moving.playing:
			moving.stop()
		if Input.is_action_pressed("move_down"):
			player.velocity.y = move_toward(player.velocity.y, target.y, player.acceleration_y * _delta)
		else:
			# Apply gravity
			player.velocity.y += player.gravity * _delta
			player.velocity.y = minf(player.velocity.y, player.max_fall_speed) 
	
	# --- COLLISIONS --- #
	const BOUNCE_FACTOR: float = 0.9
	const FLOOR_BOUNCE_FACTOR: float = 0.8
	const MAX_BOUNCE_SPEED: float = 4300.0
	var holding_down := Input.is_action_pressed("move_down")
	var pre_velocity := player.velocity

	player.move_and_slide()

	for i in player.get_slide_collision_count():
		var c := player.get_slide_collision(i)
		var n := c.get_normal()
		var is_floor := n.y < -0.5
		var is_ceiling := n.y > 0.5
		var is_wall := absf(n.x) > 0.5
		var impact := absf(pre_velocity.dot(n))
		
		if is_floor:
			if holding_down:
				player.velocity = pre_velocity.bounce(n) * FLOOR_BOUNCE_FACTOR
				player.velocity = player.velocity.limit_length(MAX_BOUNCE_SPEED)
				if impact > 550.0:
					if not bump_heavy.playing:
						bump_heavy.play()
			continue
		
		if is_ceiling:
			player.velocity = pre_velocity.bounce(n) * BOUNCE_FACTOR
			if impact > 550.0:
				if not bump_heavy.playing:
					bump_heavy.play()
				animated_sprite_2d.play("bounce_up")
			continue
		
		if is_wall:
			player.velocity = pre_velocity.bounce(n) * BOUNCE_FACTOR
			if impact > 200.0:
				if not bump_heavy.playing:
					bump_heavy.play()
				if n.x < 0:
					animated_sprite_2d.play("bounce")
				else:
					animated_sprite_2d.play("bounce")
			continue
	
	# --- REFILL --- #
	if player.is_on_floor() and not Input.is_action_pressed("move_down"):
		flight_bar = minf(flight_bar + player.flight_refill_time * _delta, player.flight_max_time)
		
	# Update flight bar
	flight_bar_updated.emit(flight_bar)

func handle_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("select"):
		finished.emit(SELECTING, { "flight_bar" : flight_bar })
	
	# Flipping logic plays first so the audio await code does not block it
	if (Input.is_action_just_pressed("move_right")):
		animated_sprite_2d.flip_h = true
	if (Input.is_action_just_pressed("move_left")):
		animated_sprite_2d.flip_h = false

# --- HELPER FUNCTIONS --- #
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

# --- SIGNAL CALLBACKS --- #
func _on_animation_finished() -> void:
	if animated_sprite_2d.animation == "bounce":
		animated_sprite_2d.play("bob")

func _on_flight_bar_updated(flight_left: float) -> void:
	h_slider.value = flight_left
