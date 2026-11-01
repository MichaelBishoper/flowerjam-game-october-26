extends CanvasLayer

@export var exit: Button
@export var music_slider: HSlider
@export var sfx_slider: HSlider
@export var ui_slider: HSlider
@onready var restart_hover: AudioStreamPlayer = $"../RestartHover"
@onready var ui_click: AudioStreamPlayer = $"../UiClick"
@onready var ui_hover: AudioStreamPlayer = $"../UiHover"

func _ready() -> void:
	# Set the slider volumes to the autoload's
	music_slider.value = SettingsAutoload.music_volume
	sfx_slider.value = SettingsAutoload.sfx_volume
	ui_slider.value = SettingsAutoload.ui_volume
	
## Helper to set bus volumes and clamp to a limit
func _apply_volume(bus_name: String, value: float, max_value := 1.0) -> void:
	var bus := AudioServer.get_bus_index(bus_name)
	# Clamps the volume between a linear range of 0.0 and 1.0
	AudioServer.set_bus_volume_db(bus, linear_to_db(clampf(value, 0.0, max_value)))

func _on_music_slider_value_changed(value: float) -> void:
	SettingsAutoload.music_volume = value
	_apply_volume("Music Bus", value)

func _on_sfx_slider_value_changed(value: float) -> void:
	SettingsAutoload.sfx_volume = value
	_apply_volume("SFX Bus", value)

func _on_ui_slider_value_changed(value: float) -> void:
	SettingsAutoload.ui_volume = value
	_apply_volume("UI Bus", value, 2.0)

func _on_exit_pressed() -> void:
	ui_click.play()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_exit_mouse_entered() -> void:
	ui_hover.play()
