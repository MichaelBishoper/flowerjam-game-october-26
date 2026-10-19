class_name SelectingState extends PlayerState

@onready var animated_sprite_2d: AnimatedSprite2D = $"../../AnimatedSprite2D"

# TODO: When the previous state is "MOVING" make it so the player still moves but at a slower speed

func enter(previous_state_path: String, data := {}) -> void:
	print("Previous State: ", previous_state_path)
	print("Current State: Selecting")
	
	animated_sprite_2d.show()

func handle_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("select"):
		finished.emit(IDLE)

func exit() -> void:
	pass
