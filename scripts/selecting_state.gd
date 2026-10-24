class_name SelectingState extends PlayerState

@onready var animated_sprite_2d: AnimatedSprite2D = $"../../AnimatedSprite2D"
@onready var camera_2d: Camera = $"../../../Camera2D"
@onready var circle_overlay: CanvasLayer = $"../../CircleOverlay"
@onready var selecting: AudioStreamPlayer = $"../../Selecting"

var dim_overlay: CanvasLayer

func enter(previous_state_path: String, data := {}) -> void:
	selecting.play()
	# Set camera to follow player
	camera_2d.set_target(player)
	dim_overlay = get_tree().get_first_node_in_group("screen_dim")	
	if dim_overlay:
		dim_overlay.dim()
	if circle_overlay:
		circle_overlay.show_circle()
	#print("Previous State: ", previous_state_path)
	#print("Current State: Selecting")
	
	animated_sprite_2d.show()

func handle_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("select"):
		finished.emit(IDLE)

func exit() -> void:
	if dim_overlay:
		dim_overlay.undim()
	if circle_overlay:
		circle_overlay.hide_circle()
