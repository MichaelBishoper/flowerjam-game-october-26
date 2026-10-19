class_name StateMachine extends Node

@export var initial_state: State = null

# Get initial state, if none selected fallback to first child
@onready var state: State = (func get_init_state() -> State:
	return initial_state if initial_state != null else get_child(0)
	).call()

signal state_changed(new_state: State, old_state: State)

func get_state() -> State:
	return state
	
func _ready() -> void:
	# Finds all nodes whose script contains class_name State and connects each of them to a transition function
	for state_node: State in find_children("*", "State"):
		state_node.finished.connect(_transition_to_next_state)
	
	await owner.ready
	# Initial state enters with an empty previous state
	state.enter("")

func _unhandled_input(event: InputEvent) -> void:
	state.handle_input(event)

func _process(delta: float) -> void:
	state.update(delta)

func _physics_process(delta: float) -> void:
	state.physics_update(delta)

func _transition_to_next_state(target_state_path: String, data: Dictionary = {}) -> void:
	if not has_node(target_state_path):
		printerr(owner.name + target_state_path + "does not exist")
		return
	var previous_state_path := state.name
	state.exit()
	state = get_node(target_state_path) as State
	# Enter Function for States Gives: Previous State Only
	state.enter(previous_state_path, data)
	# State Changed Signal Gives: Previous AND Current State
	state_changed.emit(state.name, previous_state_path)
