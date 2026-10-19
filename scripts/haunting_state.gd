class_name HauntingState extends PlayerState

@onready var animated_sprite_2d: AnimatedSprite2D = $"../../AnimatedSprite2D"
@onready var camera_2d: Camera2D

var hauntable: Hauntable

func enter(previous_state_path: String, data := {}) -> void:
	# Set the camera_2d reference here and not outside!
	camera_2d = player.camera_2d
	
	print("Previous State: ", previous_state_path)
	print("Current State: Haunting")
	
	# Build a new camera2D if it doesn't exist
	# TODO: When the camera proportions are set exactly, set them in code as well here
	if camera_2d == null:
		print("I'm here")
		camera_2d = Camera2D.new()
		add_child(camera_2d)
		camera_2d.make_current()
	
	# Hide the player sprite
	animated_sprite_2d.hide()
	
	# Get the reference to the haunted node
	hauntable = data.get("object")
	if hauntable == null:
		return
	else: 
		hauntable.rigid_body_2d.lock_rotation = false
		hauntable.rigid_body_2d.freeze = false
		
func update(_delta: float) -> void:
	# Change camera's position to the hauntable's position
	if camera_2d == null:
		return
	if hauntable:
		camera_2d.global_position = hauntable.rigid_body_2d.global_position
	
func physics_update(_delta: float) -> void:
	# Feed user input into the hauntable's movement function
	var input_dir: float = Input.get_axis("move_left", "move_right")
	hauntable.move(input_dir, _delta)

func handle_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("close"):
		finished.emit(IDLE)

func exit() -> void:
	# Make player spawn back above the hauntable
	player.global_position = hauntable.rigid_body_2d.global_position + Vector2(0.0, -100.0)
	# Revert camera position back to the player's position
	camera_2d.global_position = player.global_position
	# Show the player sprite
	animated_sprite_2d.show()
