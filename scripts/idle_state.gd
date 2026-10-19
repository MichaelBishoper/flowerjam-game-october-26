class_name IdleState extends PlayerState

@onready var animated_sprite_2d: AnimatedSprite2D = $"../../AnimatedSprite2D"

func enter(previous_state_path: String, data := {}) -> void:
	print("Previous State: ", previous_state_path)
	print("Current State: Idle")
	
	player.velocity.x = 0.0
	player.velocity.y = 0.0
	
	animated_sprite_2d.show()
	animated_sprite_2d.play("temporary_secretary")
	

func physics_update(_delta: float) -> void:
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
