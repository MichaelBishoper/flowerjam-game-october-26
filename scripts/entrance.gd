extends Area2D

@export var door_swing_close: AudioStreamPlayer2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _process(delta: float) -> void:
	if animated_sprite_2d.animation == "door_swing_close":	
		if not door_swing_close.playing:
			door_swing_close.play()
