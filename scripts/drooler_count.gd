extends Label

func _ready() -> void:
	SettingsAutoload.drooler_collected.connect(_on_drooler_collected)
	_update_label(SettingsAutoload.droolers_collected)
	
func _on_drooler_collected(value: int) -> void:
	_update_label(SettingsAutoload.droolers_collected)
	
func _update_label(value: int) -> void:
	text = str(value)
