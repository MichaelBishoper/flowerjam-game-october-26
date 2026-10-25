class_name IdleState extends PlayerState

@onready var animated_sprite_2d: AnimatedSprite2D = $"../../AnimatedSprite2D"
@onready var camera_2d: Camera = $"../../../Camera2D"

# SFX Players
@onready var press_right: AudioStreamPlayer2D = $"../../PressRight"
@onready var press_left: AudioStreamPlayer2D = $"../../PressLeft"
@onready var press_down: AudioStreamPlayer2D = $"../../PressDown"
@onready var press_up: AudioStreamPlayer2D = $"../../PressUp"

func enter(previous_state_path: String, data := {}) -> void:
	# Set camera to follow player
	camera_2d.set_target(player)
	
	#print("Previous State: ", previous_state_path)
	#print("Current State: Idle")
	
	player.velocity.x = 0.0
	player.velocity.y = 0.0
	
	animated_sprite_2d.show()
	animated_sprite_2d.play("bob")

func physics_update(_delta: float) -> void:
	# Apply gravity
	player.velocity.y += player.gravity * _delta
	player.velocity.y = minf(player.velocity.y, player.max_fall_speed)
	
	# If player is falling then switch to MOVING
	if player.velocity.y != 0.0:
		finished.emit(MOVING)
		
	player.move_and_slide()

func handle_input(_event: InputEvent) -> void:
	# State Change -> Moving
	if (Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")
		or Input.is_action_pressed("move_down") or Input.is_action_pressed("move_up")
	):
		finished.emit(MOVING)
	# State Change -> Selecting
	if Input.is_action_just_pressed("select"):
		finished.emit(SELECTING)
		
	# Playing Audio
	if (Input.is_action_just_pressed("move_right")):
		press_right.play()
	if (Input.is_action_just_pressed("move_left")):
		press_left.play()
	if (Input.is_action_just_pressed("move_down")):
		press_down.play()
	if (Input.is_action_just_pressed("move_up")):
		press_up.play()
