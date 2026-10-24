class_name ButtonController extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_detection: Area2D = $CollisionDetection
@onready var button_top: StaticBody2D = $ButtonTop
@onready var button_base: StaticBody2D = $ButtonBase

# State Machine Variables
enum State { PRESSED, IDLE, HELD, RELEASED }
@export var current_state = State.IDLE
var previous_state: ButtonController.State
var hauntables_on_button: Array[RigidBody2D] = []

func _ready() -> void:
	# Connect the Area2D's signals to local function
	collision_detection.body_exited.connect(_on_body_exited)
	collision_detection.body_entered.connect(_on_body_entered)
	
func _process(delta: float) -> void:
	_handle_state_transitions()
	_execute_state_logic()

# -- STATE LOGIC -- #
func _handle_state_transitions() -> void:
	match current_state:
		State.IDLE:
			if not hauntables_on_button.is_empty():
				_switch_state(State.PRESSED)
			if hauntables_on_button.is_empty() and previous_state == State.HELD:
				_switch_state(State.RELEASED)
		State.PRESSED:
			# State Transitions are in _execute_state_logic()
			pass
		State.HELD:
			if hauntables_on_button.is_empty():
				_switch_state(State.IDLE)
		State.RELEASED:
			# State Transitions are in _execute_state_logic()
			pass

func _execute_state_logic() -> void:
	match current_state:
		State.IDLE:
			animation_player.play("RESET")
		State.PRESSED:
			animation_player.play("pressed")
			await animation_player.animation_finished
			# Switch state to HELD
			_switch_state(State.HELD)
		State.HELD:
			animation_player.play("pressed_still")
			if hauntables_on_button.is_empty():
				_switch_state(State.RELEASED)
		State.RELEASED:
			animation_player.play("released")	
			await animation_player.animation_finished
			_switch_state(State.IDLE)

func _switch_state(new_state: ButtonController.State) -> void:
	if current_state == new_state:
		return
	previous_state = current_state
	# Exit state functions
	current_state = new_state
	#  Enter State functions

func _on_body_entered(body: RigidBody2D) -> void:
	if body == button_top or body == button_base or body.is_in_group("player"):
		return
	# Debug
	#print("Entered: ", body)
	hauntables_on_button.append(body)

func _on_body_exited(body: RigidBody2D) -> void:
	# Debug
	#print("Exited: ", body)
	hauntables_on_button.erase(body)
