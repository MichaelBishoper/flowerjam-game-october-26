extends Button
# TODO: Create sound effects for restart and restart hover
@onready var restart_click: AudioStreamPlayer = $"../../RestartClick"
@onready var restart_hover: AudioStreamPlayer = $"../../RestartHover"
@onready var state_machine: StateMachine = $"../../StateMachine"

var tween: Tween

func _ready() -> void:
	disabled = false
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pressed.connect(_on_button_pressed)
	
func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if state_machine.state.name == "Selecting":
		return
	if state_machine.state.name == "Haunting":
		return
	if state_machine.state.name == "Idle":
		return
	if get_tree().paused:
		return
	if Input.is_action_just_pressed("restart"):
		if tween and tween.is_running():
			tween.kill()
		tween = create_tween()
		tween.tween_property(self, "rotation_degrees", 82.0, 0.2
		).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "rotation_degrees", 0.0, 0.2
		).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		restart_hover.play()

func _on_mouse_entered() -> void:
	if state_machine.state.name == "Haunting" or state_machine.state.name == "Selecting" or state_machine.state.name == "Idle" or get_tree().paused:
		if tween and tween.is_running():
			tween.kill()
		tween = create_tween()
		tween.tween_property(self, "rotation_degrees", 0.0, 0.15)
		return
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "rotation_degrees", 82.0, 1.2
	).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	restart_hover.play()

func _on_mouse_exited() -> void:
	if state_machine.state.name == "Haunting" or state_machine.state.name == "Selecting" or state_machine.state.name == "Idle" or get_tree().paused:
		if tween and tween.is_running():
			tween.kill()
		tween = create_tween()
		tween.tween_property(self, "rotation_degrees", 0.0, 0.15)
		return
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "rotation_degrees", 0.0, 0.38
	).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

func _on_button_pressed() -> void:
	restart_click.play()
