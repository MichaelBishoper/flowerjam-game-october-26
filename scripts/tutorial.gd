class_name Tutorial extends CanvasLayer

@export var arrow: TextureRect
@export var text: Label

var _tutorial_text: Array[String] = [
	"Press A, S and D to move",
	"Press SPACE to fly",
	"Press C to enter haunting",
	"Choose an object to haunt",
	"Move using A and S as the object",
	"Press X to exit haunting",
]

var _step_index: float = 0

func _ready() -> void:
	text.modulate.a = 0.0

func _process(delta: float) -> void:
	print("Is paused: ", get_tree().paused)
	if SettingsAutoload.tutorial_done or get_tree().paused:
		visible = false
	else: 
		visible = true

func show_current_step() -> void:
	await fade_text(text, false)
	text.text = _tutorial_text[_step_index]
	await fade_text(text, true)
	
func advance() -> bool:
	_step_index += 1
	if _step_index >= _tutorial_text.size():
		SettingsAutoload.tutorial_done = true
		return false
	return true

func fade_text(label: Label, to_visible: bool, duration: float = 0.3) -> void:
	var tween := label.create_tween()
	tween.tween_property(label, "modulate:a", 1.0 if to_visible else 0.0, duration)
	await tween.finished
