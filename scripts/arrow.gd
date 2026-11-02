extends Sprite2D

@onready var state_machine: StateMachine = $"../StateMachine"
var _fade_tween: Tween

func _ready() -> void:
	fade_arrow(false, 0.01)

func _process(delta: float) -> void:
	if state_machine.state.name != "Moving":
		fade_arrow(false, 0.1)

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_pressed("move_down"):
		fade_arrow(true, 0.2)
	if Input.is_action_just_released("move_down"):
		fade_arrow(false, 0.1)

## to_visible = false makes the arrow fade out, to_visible = true makes the arrow fade in
func fade_arrow(to_visible: bool, duration: float = 0.3) -> void:
	if _fade_tween and _fade_tween.is_running():
		_fade_tween.kill()
	_fade_tween = create_tween()
	_fade_tween.tween_property(self, "modulate:a", 1.0 if to_visible else 0.0, duration)
	await _fade_tween.finished
