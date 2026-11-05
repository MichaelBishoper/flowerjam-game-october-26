extends Node2D

@export var area_2d: Area2D
@export var animation_player: AnimationPlayer

var _can_collect := true

func _ready() -> void:
	area_2d.body_entered.connect(_on_body_entered)
	animation_player.play("hover")

func _on_body_entered(body: Node) -> void:
	if not _can_collect:
		return
	if body.is_in_group("player"):
		SettingsAutoload.add_drooler(1)  
		hide()
		area_2d.set_deferred("monitoring", false)
		_can_collect = false
