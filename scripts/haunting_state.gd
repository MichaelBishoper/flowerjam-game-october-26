class_name HauntingState extends PlayerState

@onready var animated_sprite_2d: AnimatedSprite2D = $"../../AnimatedSprite2D"
@onready var camera_2d: Camera = $"../../../Camera2D"

# The current hauntable node, defined in the enter() function below
var hauntable: Hauntable

func enter(previous_state_path: String, data := {}) -> void:	
	#print("Previous State: ", previous_state_path)
	#print("Current State: Haunting")
	
	# Hide the player sprite
	animated_sprite_2d.hide()
	
	# Get the reference to the haunted node
	hauntable = data.get("object")
	if hauntable == null:
		return
	else: 
		hauntable.rigid_body_2d.lock_rotation = false
		hauntable.rigid_body_2d.freeze = false
		
	# Lock the camera to the hauntable's rigid body
	camera_2d.set_target(hauntable.rigid_body_2d)
		
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
	#  TODO: Change this with OBJECT HEIGHT
	player.global_position = hauntable.rigid_body_2d.global_position + Vector2(0.0, -100.0)
	# Set camera's target back to player
	camera_2d.set_target(player)
	# Show the player sprite
	animated_sprite_2d.show()
