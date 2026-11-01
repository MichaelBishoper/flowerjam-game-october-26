class_name IdleState extends PlayerState

@onready var animated_sprite_2d: AnimatedSprite2D = $"../../AnimatedSprite2D"
@onready var camera_2d: Camera = $"../../../Camera2D"

# SFX Players
@onready var press_right: AudioStreamPlayer2D = $"../../PressRight"
@onready var press_left: AudioStreamPlayer2D = $"../../PressLeft"
@onready var press_down: AudioStreamPlayer2D = $"../../PressDown"
@onready var press_up: AudioStreamPlayer2D = $"../../PressUp"
@onready var restart: Button = $"../../UI/Restart"
@onready var settings: Button = $"../../UI/Settings"

var flight_bar: float

func enter(previous_state_path: String, data := {}) -> void:
	# Set camera to follow player
	camera_2d.set_target(player)
	
	# Get flight_bar
	flight_bar = data.get("flight_bar")
	
	# Disable the restart button
	restart.disabled = true
	
	#print("Previous State: ", previous_state_path)
	#print("Current State: Idle")
	
	player.velocity.x = 0.0
	player.velocity.y = 0.0
	
	animated_sprite_2d.show()
	animated_sprite_2d.play("temporary_secretary")

func physics_update(_delta: float) -> void:
	pass
	
func exit() -> void:
	restart.disabled = false

func handle_input(_event: InputEvent) -> void:
	pass
