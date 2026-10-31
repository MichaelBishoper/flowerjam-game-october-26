extends Label
@onready var timer: Timer = $Timer

# UGLY ASS CODE WARNING
## Typewrite the label's text content, waits for the tween to finish
func typewrite(target_text: String, chars_per_second: float = 13.5, init_delay: float = 1.5) -> void:
	timer.wait_time = init_delay
	timer.start()
	await timer.timeout
	visible = true
	text = target_text
	visible_characters = 0
	var duration := text.length() / chars_per_second
	var text_tween := create_tween()
	text_tween.tween_property(self, "visible_characters", text.length(), duration)
	await text_tween.finished
	await get_tree().create_timer(1.0)
	var fade_tween := create_tween()
	fade_tween.tween_property(self, "modulate:a", 0.0, 3.0)
	await fade_tween.finished
	visible = false
