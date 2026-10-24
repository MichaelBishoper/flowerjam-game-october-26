class_name Trapdoor extends Node2D

@onready var trapdoor: RigidBody2D = $Trapdoor
@onready var pin_joint_2d: PinJoint2D = $PinJoint2D
@onready var wall: StaticBody2D = $Wall

# trapdoor Open/Close Logic Variables
@export var closed_angle := 0.0
@export var open_angle := -PI / 2.0 # -90 Degrees
@export var motor_speed := 3.0
var tolerance := 0.05

# State Machine Variables
enum State { IDLE, OPENING, OPENED, CLOSING }	
@export var current_state = State.IDLE
var previous_state = Trapdoor.State

# -- PUBLIC METHODS -- #
func open() -> void:
	if current_state == State.OPENING or current_state == State.OPENED:
		return
	_switch_state(State.OPENING)

func close() -> void:
	if current_state == State.CLOSING or current_state == State.IDLE:
		return
	_switch_state(State.CLOSING)

func is_open() -> bool:
	return current_state == State.OPENED

func is_closed() -> bool:
	return current_state == State.IDLE

# -- PRIVATE METHODS -- #
# Boolean function which returns true when the target angle is reached and stops the rotation physics of the trapdoor
func _drive_to_angle(target_angle: float, tolerance: float = tolerance) -> bool:
	# Get the difference in angle of the trapdoor and the
	var diff := angle_difference(trapdoor.rotation, target_angle)
	if abs(diff) < tolerance:
		# Make the pin joint stop rotating the trapdoor if the angle difference is within the tolerance level
		pin_joint_2d.motor_enabled = false
		trapdoor.angular_velocity = 0.0
		trapdoor.rotation = target_angle
		return true
	pin_joint_2d.motor_enabled = true
	# Give target velocity direction + magnitude
	pin_joint_2d.motor_target_velocity = sign(diff) * motor_speed
	return false

# Returns TRUE when trapdoor is fully OPEN 
func _drive_open() -> bool:
	return _drive_to_angle(open_angle)
	
# Returns TRUE when trapdoor is fully CLOSED
func _drive_close() -> bool:
	return _drive_to_angle(closed_angle)
	
# Function to stop all motion
func _stop_motor() -> void:
	pin_joint_2d.motor_enabled = false
	trapdoor.angular_velocity = 0.0
	trapdoor.gravity_scale = 0.0
	# NOTE: You have to set the gravity to 0.0 so it doesn't fall!
	trapdoor.freeze = true

func _resume_motor() -> void:
	trapdoor.freeze = false
	trapdoor.gravity_scale = 1.0
	
func _physics_process(delta: float) -> void:
	_execute_state_logic()

# -- STATE MACHINE METHODS -- #
		
func _execute_state_logic() -> void:
	match current_state:
		State.IDLE:
			_stop_motor()
		State.OPENING:
			_resume_motor()
			var reached := _drive_open()
			# Immediately switch to OPENED when trapdoor is opened
			if reached: 
				_switch_state(State.OPENED)
		State.OPENED:
			_stop_motor()
		State.CLOSING:
			_resume_motor()
			var reached := _drive_close()
			# Immediately switch to IDLE when trapdoor is closed
			if reached:
				_switch_state((State.IDLE))

## TEMPORARY: for debug	
#func _unhandled_input(event: InputEvent) -> void:
	#match current_state:
		#State.IDLE:
			#if Input.is_action_just_pressed("debug_button_1"):
				#_switch_state(State.OPENING)
		#State.OPENING:
			#if Input.is_action_just_pressed("debug_button_2"):
				#_switch_state(State.CLOSING)
		#State.OPENED:
			#if Input.is_action_just_pressed("debug_button_2"):
				#_switch_state(State.CLOSING)
		#State.CLOSING:
			#if Input.is_action_just_pressed("debug_button_1"):
				#_switch_state(State.OPENING)

func _switch_state(new_state: Trapdoor.State) -> void:
	if current_state == new_state:
		return
	previous_state = current_state
	# Exit state functions
	current_state = new_state
	# Debug:
	# print(State.find_key(current_state))
	# Enter State functions
