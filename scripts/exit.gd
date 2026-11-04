extends Area2D

@export var door_swing_closed: AudioStreamPlayer2D
@export var animated_sprite_2d: AnimatedSprite2D

func _process(delta: float) -> void:
	if animated_sprite_2d.is_playing() and animated_sprite_2d.animation == "door_swing_close":
		if not door_swing_closed.playing:
			door_swing_closed.play()
