class_name Player extends CharacterBody2D

@onready var haunt_detection: Area2D = $HauntDetection
@onready var state_machine: StateMachine = $StateMachine
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera_2d: Camera2D = $"../Camera2D"
@onready var selecting: SelectingState = $StateMachine/Selecting

# Movement variables (y coordinate movement is unused now, still too scared to delete it LOL)
@export var max_speed_x := 750.0
@export var max_speed_y := 800.0
@export var acceleration_x := 900.0
@export var acceleration_y := 1000.0
@export var friction_x := 200.0
@export var friction_y := 400.0

# Gravity variables
@export var gravity := 990.0
@export var max_fall_speed := 1200.0

# Flight variables
@export var flight_max_time := 0.7
@export var flight_acceleration := -900.0
@export var flight_refill_time := 1.5
@export var hover_height := 200.0
@export var hover_snap := 4.0

# FOR THE ARROW DEBUGS
@export var arrow_scene: PackedScene

# DEBUG MODE
var debug_mode := false

# For Debug Arrow
const ARROW_COLOR_VISIBLE := Color(0.0, 0.1, 1.0, 1.0)   # blue = normal
const ARROW_COLOR_BLOCKED := Color(1.0, 0.0, 0.0, 1.0)   # red = blocked
const ARROW_BASE_LENGTH := 1.0
var arrows: Dictionary = {}

# For Hauntable
var hauntables: Array[RigidBody2D] = [] # Hauntables that are in range of the player
var available_hauntables: Array[RigidBody2D] = [] # Hauntables that are in range and can be haunted by the player
signal hauntable_array_changed

func _ready() -> void:
	# Add player to a node group called "player"
	add_to_group("player")

func _process(delta: float) -> void:
	# Emits a signal that sends a list of ALL hauntables and AVAILABLE hauntables
	_update_available_hauntables()
	hauntable_array_changed.emit(hauntables, available_hauntables)
	
	# Turn on and off for Debug Lines
	debug_mode = false
	if debug_mode:
		
		# -- DEBUG LINE CREATION LOGIC -- #
		
		# Remove arrows whose target is no longer in range / current state is haunting
		for target in arrows.keys():
			if not is_instance_valid(target) or not hauntables.has(target) or state_machine.state.name == "Haunting":
				arrows[target].queue_free()
				arrows.erase(target)
		
		# Create arrows only if the current state is not haunting
		if state_machine.state.name != "Haunting":
			for target in hauntables:
				var arrow: Line2D = arrows.get(target)
				if arrow == null:
					arrow = arrow_scene.instantiate() as Line2D
					add_child(arrow)
					arrows[target] = arrow
				
				# NOTE: IF THIS DOESN'T WORK THEN DON'T USE DEBUG
				arrow.global_position = global_position
				arrow.rotation = (target.global_position - global_position).angle()
				var distance := global_position.distance_to(target.global_position)
				arrow.scale.x = (distance - 130.0) / ARROW_BASE_LENGTH
				
				arrow.modulate = ARROW_COLOR_BLOCKED if _is_hauntable_blocked(target) else ARROW_COLOR_VISIBLE
		else: return
	else: return
		# -- END OF DEBUG LINE CREATION LOGIC -- #

# Checks if a hauntable object is blocked by a tilemap wall
func _is_hauntable_blocked(node: Node2D) -> bool:
	var space := get_world_2d().direct_space_state
	var params := PhysicsRayQueryParameters2D.create(global_position, node.global_position)
	# NOTE: CHANGE THIS IF YOU CHANGE THE COLLISION LAYER OF THE TILEMAP
	params.collision_mask = 1
	params.exclude = [self, node]
	var hit := space.intersect_ray(params)
	# Return true if "hit" is not empty
	if hit != {}:
		return true
	return false

# Reutns the node of the closest hauntable
func _get_nearest_hauntable() -> Node2D:
	var nearest: Node2D = null
	var best := INF
	for node in hauntables:
		if _is_hauntable_blocked(node):
			continue
		var d := global_position.distance_squared_to(node.global_position)
		if d < best:
			best = d
			nearest = node
	return nearest
	
# Function to update the available hauntables and hauntables array
func _update_available_hauntables() -> void:
	available_hauntables.clear()
	for body in hauntables:
		if _is_hauntable_blocked(body):
			continue
		available_hauntables.append(body)
	

func _on_haunt_detection_body_entered(body: Node2D) -> void:
	hauntables.append(body)

func _on_haunt_detection_body_exited(body: Node2D) -> void:
	hauntables.erase(body)
	available_hauntables.erase(body)

# SELECTING to HAUNTING state logic is here
func _on_haunt_button_pressed(body: Hauntable) -> void:
	# BODY is a reference to the Node2D of the haunted object
	# Don't show shader once the button is flashed
	body.hide_shader()
	animated_sprite_2d.play("haunt")
	await animated_sprite_2d.animation_finished
	# Transition to the haunting state with a reference to the haunted node!
	state_machine._transition_to_next_state("Haunting", { "object": body, "flight_bar" : selecting.flight_bar })
