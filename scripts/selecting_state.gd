class_name SelectingState extends PlayerState

@onready var animated_sprite_2d: AnimatedSprite2D = $"../../AnimatedSprite2D"
## The restart button
@onready var restart: Button = $"../../UI/Restart"
@onready var camera_2d: Camera = $"../../../Camera2D"
@onready var circle_overlay: CanvasLayer = $"../../CircleOverlay"
@onready var selecting: AudioStreamPlayer = $"../../Selecting"
@onready var moving: AudioStreamPlayer2D = $"../../Moving"
@export var settings: Button

var dim_overlay: CanvasLayer
var flight_bar: float

func enter(previous_state_path: String, data := {}) -> void:
	restart.disabled = true
	settings.disabled = true
	
	if moving.playing:
		moving.stop()

	animated_sprite_2d.play("temporary_secretary")
	
	# Get the last flight bar from the moving state
	flight_bar = data.get("flight_bar")
	selecting.play()
	# Set camera to follow player
	camera_2d.set_target(player)
	dim_overlay = get_tree().get_first_node_in_group("screen_dim")	
	if dim_overlay:
		dim_overlay.dim()
	if circle_overlay:
		circle_overlay.show_circle()
		
	print("Previous State: ", previous_state_path)
	print("Current State: Selecting")
	
	animated_sprite_2d.show()

func handle_input(_event: InputEvent) -> void:
	# State Transitions
	if Input.is_action_just_pressed("select"):
		finished.emit(MOVING, { "flight_bar" : flight_bar })

func exit() -> void:
	restart.disabled = false
	settings.disabled = false
	if dim_overlay:
		dim_overlay.undim()
	if circle_overlay:
		circle_overlay.hide_circle()
