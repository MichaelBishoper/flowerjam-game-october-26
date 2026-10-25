class_name ButtonController extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_detection: Area2D = $CollisionDetection
@onready var button_top: StaticBody2D = $ButtonTop
@onready var button_base: StaticBody2D = $ButtonBase

@export var trapdoor: Trapdoor

# Player and StateMachine references are defined in _ready()
var player: Player
var state_machine: StateMachine
var player_state: String

# State Machine Variables
enum State { PRESSED, IDLE, HELD, RELEASED }
@export var current_state = State.IDLE
var previous_state: ButtonController.State

# Tracks all rigidbody2Ds that are on the button
var hauntables_on_button: Array[RigidBody2D] = []

func _ready() -> void:
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
		
	# Connect the Area2D's signals to local function
	collision_detection.body_exited.connect(_on_body_exited)
	collision_detection.body_entered.connect(_on_body_entered)
	# Connect the StateMachine's signal to local function
	state_machine.state_changed.connect(_on_player_state_changed)
	
func _process(delta: float) -> void:
	_handle_state_transitions()
	_execute_state_logic()

func _physics_process(delta: float) -> void:
	pass

# -- STATE LOGIC -- #
func _handle_state_transitions() -> void:
	match current_state:
		State.IDLE:
			if _is_all_light():
				return
			if not hauntables_on_button.is_empty():
				_switch_state(State.PRESSED)
			if hauntables_on_button.is_empty() and previous_state == State.HELD:
				_switch_state(State.RELEASED)
		State.PRESSED:
			# State Transitions are in _execute_state_logic()
			pass
		State.HELD:
			if _is_all_light():
				_switch_state(State.RELEASED)
			if hauntables_on_button.is_empty():
				_switch_state(State.IDLE)
		State.RELEASED:
			# State Transitions are in _execute_state_logic()
			pass

func _execute_state_logic() -> void:
	match current_state:
		State.IDLE:
			trapdoor.close()
			animation_player.play("RESET")
		State.PRESSED:
			trapdoor.open()
			animation_player.play("pressed")
			await animation_player.animation_finished
			# After animation finishes Switch state to HELD
			_switch_state(State.HELD)
		State.HELD:
			trapdoor.open()
			animation_player.play("pressed_still")
			if hauntables_on_button.is_empty():
				_switch_state(State.RELEASED)
		State.RELEASED:
			trapdoor.close()
			animation_player.play("released")	
			await animation_player.animation_finished
			# After animation finishes Switch state to IDLE
			_switch_state(State.IDLE)

func _switch_state(new_state: ButtonController.State) -> void:
	if current_state == new_state:
		return
	previous_state = current_state
	# Exit state functions
	current_state = new_state
	#  Enter State functions

func _is_all_light() -> bool:
	for h in hauntables_on_button:
		if not h.is_in_group("light"):
			return false
	return true

# Append the hauntable rigidbody2d to the array
func _on_body_entered(body: RigidBody2D) -> void:
	if body == button_top or body == button_base or body.is_in_group("player"):
		return
	# Debug
	#print("Entered: ", body)
	hauntables_on_button.append(body)

# Remove the hauntable rigidbody2d from the array
func _on_body_exited(body: RigidBody2D) -> void:
	# Debug
	#print("Exited: ", body)
	hauntables_on_button.erase(body)

func _on_player_state_changed(new_state: String, old_state: String) -> void:
	player_state = new_state
