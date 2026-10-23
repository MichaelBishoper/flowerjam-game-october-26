class_name Hauntable extends Node2D

@export var speed := 400.0

@onready var haunt_button: Button = $HauntButton
@onready var rigid_body_2d: RigidBody2D = $RigidBody2D

# Haunt Audio
@onready var haunt: AudioStreamPlayer2D = $Haunt

# Player and StateMachine references are defined in _ready()
var player: Player
var state_machine: StateMachine

var player_state: String
var hauntables_array: Array[RigidBody2D]
var available_hauntables_array: Array[RigidBody2D]
var is_in_range: bool = false

# For the Public Methods
@export var hauntable_acceleration := 1200.0
@export var hauntable_max_speed := 400.0

signal button_pressed

# For physics material properties
@export_range(0.0, 1.0) var bounce_factor = 0.6
@export_range(0.0, 1.0) var friction_factor = 0.5

# -- CLASS METHODS -- #
	
func move(axis: float, delta: float) -> void:
	# Movement logic
	var target_x  := axis * hauntable_max_speed
	
	if axis != 0.0:
		rigid_body_2d.linear_velocity.x = move_toward(
			rigid_body_2d.linear_velocity.x, target_x, hauntable_acceleration * delta 
		)
	
# -- END OF CLAS METHODS -- #



# -- PRIVATE METHODS -- #

func _ready() -> void:
	# WHY DOES THIS FIX IT????
	await get_tree().process_frame
	
	var mat := PhysicsMaterial.new()
	mat.bounce = bounce_factor
	mat.friction = friction_factor
	rigid_body_2d.physics_material_override = mat
	
	# Define Player Reference
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		push_warning("You are utterly fucked")
		return
	
	# Define StateMachine Reference
	state_machine = player.state_machine
	if state_machine == null:
		push_warning("You are utterly fucked")
		return
	
	# Connect the state machine's player_changed signal to local private function
	state_machine.state_changed.connect(_on_player_state_changed)
	# Connect the player's hauntable_array_changed to local private function
	player.hauntable_array_changed.connect(_on_hauntable_array_changed)
	# Connect the haunt button's pressed signal to local private function
	haunt_button.pressed.connect(_on_haunt_button_pressed)
	# Connect the local signal button_pressed to the player's local function
	button_pressed.connect(player._on_haunt_button_pressed)
	# Set the rigid body's gravity scale
	rigid_body_2d.gravity_scale = 1.0
	
	# Hide haunt button
	haunt_button.hide()
	
func _process(delta: float) -> void:
	# If Player State is Selecting and Object is hauntable then Show the haunt button and freeze the rigid body
	if available_hauntables_array.has(rigid_body_2d) and player_state == "Selecting":
		rigid_body_2d.freeze = true
		haunt_button.position = rigid_body_2d.position + Vector2(-100.0, -250.0)
		haunt_button.show()
	else:
		haunt_button.hide()
		rigid_body_2d.freeze = false


# Updates the player_state variable
func _on_player_state_changed(new_state: String, old_state: String) -> void:
	player_state = new_state

# Updates the hauntables_array variable
func _on_hauntable_array_changed(hauntables: Array[RigidBody2D], available_hauntables: Array[RigidBody2D]) -> void:
	hauntables_array = hauntables
	available_hauntables_array = available_hauntables

# Emits the Node2D where the button was clicked
func _on_haunt_button_pressed() -> void:
	haunt.play()
	button_pressed.emit(self)
