extends Node

@onready var node_2d: Hauntable = $".."
@onready var rigid_body_2d: RigidBody2D = $"../RigidBody2D"
@onready var arrow_up: Sprite2D = $ArrowUp
@onready var arrow_down: Sprite2D = $ArrowDown

var _fade_tween: Tween

func _ready() -> void:
	arrow_down.modulate.a = 0.0
	arrow_up.modulate.a = 0.0

## to_visible = false makes the arrow fade out, to_visible = true makes the arrow fade in
func fade_arrow(arrow: Sprite2D, to_visible: bool, duration: float = 0.3) -> void:
	if _fade_tween and _fade_tween.is_running():
		_fade_tween.kill()
	_fade_tween = create_tween()
	_fade_tween.tween_property(arrow, "modulate:a", 1.0 if to_visible else 0.0, duration)
	await _fade_tween.finished
