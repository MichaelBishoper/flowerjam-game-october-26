extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	add_to_group("screen_dim")
	process_mode = Node.PROCESS_MODE_ALWAYS

func dim(target_alpha: float = 0.2, duration: float = 0.3) -> void:
	show()
	var tween := create_tween()
	tween.tween_property(color_rect, "color:a", target_alpha, duration)
	
func undim(duration: float = 0.3) -> void:
	var tween := create_tween()
	tween.tween_property(color_rect, "color:a", 0.0, duration)
