class_name RoomTransition extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	color_rect.modulate.a = 0.0

func transition_enter(duration: float = 0.5) -> void:
	var tween := create_tween()
	tween.tween_property(color_rect, "modulate:a", 1.0, duration)
	await tween.finished

func transition_exit(duration: float = 2.9) -> void:
	var tween := create_tween()
	tween.tween_property(color_rect, "modulate:a", 0.0, duration)
	await tween.finished
