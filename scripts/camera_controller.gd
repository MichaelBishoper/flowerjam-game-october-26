class_name Camera extends Camera2D

@export var smoothing := 8.0
@export var limit_transition := 0.4
@export var target: Node2D

var _limit_tween: Tween

# Public method to switch camera's targets
func set_target(node: Node2D) -> void:
	target = node

func set_room_limits(limits: Rect2) -> void:
	# If a tween hasn't finished yet kill the current one
	if _limit_tween:
		_limit_tween.kill()
	
	# set_parallel(true) -> all tweens animate at the same time and not sequentially
	_limit_tween = create_tween().set_parallel(true)
	# Shifts the limits gradually per room
	_limit_tween.tween_property(self, "limit_left", int(limits.position.x), limit_transition)
	_limit_tween.tween_property(self, "limit_right",  int(limits.end.x), limit_transition)
	_limit_tween.tween_property(self, "limit_top",    int(limits.position.y), limit_transition)
	_limit_tween.tween_property(self, "limit_bottom", int(limits.end.y), limit_transition)

func _process(delta: float) -> void:
	if target:
		global_position = global_position.lerp(target.global_position, smoothing * delta)
