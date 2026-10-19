class_name MovingState extends PlayerState	

@onready var animated_sprite_2d: AnimatedSprite2D = $"../../AnimatedSprite2D"


var _time_elapsed: float = 0.0

func enter(previous_state_path: String, data := {}) -> void:
	print("Previous State: ", previous_state_path)
	print("Current State: Moving")
	
	animated_sprite_2d.show()
	animated_sprite_2d.play("temporary_secretary")

func physics_update(_delta: float) -> void:
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var target := Vector2(input_dir.x * player.max_speed_x, input_dir.y * player.max_speed_y)
	
	if input_dir != Vector2.ZERO:
		player.velocity.x = move_toward(player.velocity.x, target.x, player.acceleration_x * _delta)
		player.velocity.y = move_toward(player.velocity.y, target.y, player.acceleration_y * _delta)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0.0, player.friction_x * _delta)
		player.velocity.y = move_toward(player.velocity.y, 0.0, player.friction_y * _delta)
	
	# For Animations Later!!!
	_infer_direction(input_dir)
	
	player.move_and_slide()
	
	# State Changes
	if player.velocity == Vector2.ZERO:
		finished.emit(IDLE)

func handle_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("select"):
		finished.emit(SELECTING)

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
