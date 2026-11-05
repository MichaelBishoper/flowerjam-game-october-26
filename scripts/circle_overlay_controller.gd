extends CanvasLayer

@onready var player: Player = $".."
@onready var color_rect: ColorRect = $ColorRect
@onready var shader_material: ShaderMaterial = color_rect.material as ShaderMaterial

var tween: Tween

func _process(delta: float) -> void:
	var screen_pos: Vector2 = get_viewport().get_canvas_transform() * player.global_position
	color_rect.position = screen_pos - color_rect.size * 0.5 # centers to player

func show_circle(duration: float = 0.3) -> void:
	_kill_tween()
	tween = create_tween()
	tween.tween_method(
		func(v: float): shader_material.set_shader_parameter("visibility", v),
		float(shader_material.get_shader_parameter("visibility")),
		0.4,
		duration
	)
	
func hide_circle(duration: float = 0.3) -> void:
	_kill_tween()
	tween = create_tween()
	tween.tween_method(
		func(v: float): shader_material.set_shader_parameter("visibility", v),
		float(shader_material.get_shader_parameter("visibility")),
		0.0,
		duration
	)

func _kill_tween() -> void:
	if tween and tween.is_valid():
		tween.kill()
