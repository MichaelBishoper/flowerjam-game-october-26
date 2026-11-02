extends AnimatedSprite2D

@onready var state_machine: StateMachine = $"../StateMachine"
@export var blend_speed := 20.0

var _time_elapsed := 0.0
var _frequency := 6.0
var _amplitude := 9.0

func _process(delta: float) -> void:
	_time_elapsed += delta
	position.y = sin(_time_elapsed * _frequency) * _amplitude
