extends Sprite2D

@onready var state_machine: StateMachine = $"../StateMachine"
@export var blend_speed := 8.0

var _time_elapsed := 0.0
var _frequency := 4.0
var _amplitude := 3.0

func _process(delta: float) -> void:
	_time_elapsed += delta
	var state := state_machine.state
	var weight := 1.0 - exp(-blend_speed * delta)
	
	print(weight)
	print("Local Frequency: ", _amplitude)
	print("State Frequency: ", state.bob_amplitude)
	
	_frequency = lerp(_frequency, state.bob_frequency, weight)
	_amplitude = lerp(_amplitude, state.bob_amplitude, weight)
	position.y = sin(_time_elapsed * _frequency) * _amplitude
