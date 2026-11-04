extends HSlider

@export var flight_bar_full: AudioStreamPlayer

var was_full := false
var _flash_tween: Tween
const FLASH_TIME: float = 0.1
const FLASH_COLOR: Color = Color(0.857, 0.422, 0.88, 0.306)
var _base_modulate: Color

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	step = 0.0
	_base_modulate = modulate
	
func _process(delta: float) -> void:
	var now_full: bool = value >= (max_value * 0.99)
	if now_full and not was_full:
		flash_white()
	was_full = now_full
	
func flash_white() -> void:
	flight_bar_full.play()
	if _flash_tween and _flash_tween.is_running():
		_flash_tween.kill()
	_flash_tween = create_tween()
	_flash_tween.tween_property(self, "modulate", FLASH_COLOR, FLASH_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_flash_tween.tween_property(self, "modulate", _base_modulate, 0.5)
