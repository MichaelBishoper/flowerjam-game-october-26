extends Area2D

func _ready() -> void:
	body_entered.connect(on_body_entered)

func on_body_entered(body: Player) -> void:
	if not body.is_in_group("player"):
		return
	SettingsAutoload.tutorial_done = true
