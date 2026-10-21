class_name SelectingState extends PlayerState

@onready var animated_sprite_2d: AnimatedSprite2D = $"../../AnimatedSprite2D"
@onready var camera_2d: Camera = $"../../../Camera2D"

func enter(previous_state_path: String, data := {}) -> void:
	# Set camera to follow player
	camera_2d.set_target(player)
	
	print("Previous State: ", previous_state_path)
	print("Current State: Selecting")
	
	animated_sprite_2d.show()

func handle_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("select"):
		finished.emit(IDLE)

func exit() -> void:
	pass
