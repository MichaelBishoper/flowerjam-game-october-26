extends CanvasLayer

# UI Nodes
@export var play: Button
@export var credits: Button
@export var exit: Button
@export var settings: Button
@export var music_slider: HSlider
@export var sfx_slider: HSlider
@export var ui_slider: HSlider
@export var credits_back: Button

# Control Nodes
@export var settings_wheel: Control
@export var menu: Control
@export var settings_menu: Control
@export var credits_node: Control

# SFX
@onready var button_hover: AudioStreamPlayer = $ButtonHover
@onready var button_click: AudioStreamPlayer = $ButtonClick
@onready var settings_hover: AudioStreamPlayer = $SettingsHover
@onready var settings_click: AudioStreamPlayer = $SettingsClick
@onready var play_click: AudioStreamPlayer = $PlayClick

# MUSIC
@onready var menu_music: AudioStreamPlayer = $MenuMusic

var tween: Tween

func _ready() -> void:
	# Set the volume slider values to the autoload's
	music_slider.value = SettingsAutoload.music_volume
	sfx_slider.value = SettingsAutoload.sfx_volume
	ui_slider.value = SettingsAutoload.ui_volume
	
	settings_wheel.visible = true
	menu.visible = true
	settings_menu.visible = false
	credits_node.visible = false
	# Set pivot offsets of all buttons to center
	var buttons: Array[Button] = [play, credits, exit, settings]
	for button in buttons:
		button.pivot_offset = button.size / 2.0	
	_play_audio(menu_music)

# Credits
func _on_credits_mouse_entered() -> void:
	if not menu.visible:
		return
	button_hover.play()

func _on_credits_pressed() -> void:
	button_click.play()
	credits_node.visible = true
	menu.visible = false
	
func _on_credits_back_mouse_entered() -> void:
	button_hover.play()

func _on_credits_back_mouse_exited() -> void:
	pass

func _on_credits_back_pressed() -> void:
	button_click.play()
	credits_node.visible = false
	menu.visible = true
	
# Exit
func _on_exit_mouse_entered() -> void:
	if not menu.visible:
		return
	button_hover.play()

func _on_exit_mouse_exited() -> void:
	pass
	
func _on_exit_pressed() -> void:
	if not menu.visible:
		return
	button_click.play()
	get_tree().quit()

# Play
func _on_play_mouse_entered() -> void:
	if not menu.visible:
		return
	_tween_guard(tween)
	tween = create_tween()
	tween.tween_property(play, "rotation_degrees", randf_range(1.0, 4.5), 0.08
	).set_trans(Tween.TRANS_CUBIC).set_ease(tween.EASE_IN_OUT)
	tween.tween_property(play, "rotation_degrees", randf_range(1.0, -4.5), 0.08)
	tween.tween_property(play, "rotation_degrees", 0.0, 0.1)
	button_hover.play()
	
func _on_play_pressed() -> void:
	if not menu.visible:
		return
	play_click.play()
	SettingsAutoload.droolers_collected = 0
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	
# Settings
func _on_settings_mouse_entered() -> void:
	_tween_guard(tween)
	tween = create_tween()
	tween.tween_property(settings, "rotation_degrees", 45.0, 2.0
	).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	settings_hover.play()

func _on_settings_mouse_exited() -> void:
	_tween_guard(tween)
	tween = create_tween()
	tween.tween_property(settings, "rotation_degrees", 0.0, 0.38
	).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

func _on_settings_pressed() -> void:
	if menu.visible == true:
		menu.visible = false
		settings_menu.visible = true
	elif credits_node.visible == true:
		credits_node.visible = false
		menu.visible = false
	else:
		menu.visible = true
		settings_menu.visible = false
	settings_click.play()

# SLIDERS #
# Music Slider
func _on_music_slider_value_changed(value: float) -> void:
	if not settings_menu.visible:
		return
	SettingsAutoload.music_volume = value
	_apply_volume("Music Bus", value)

func _on_sfx_slider_value_changed(value: float) -> void:
	if not settings_menu.visible:
		return
	SettingsAutoload.sfx_volume = value
	_apply_volume("SFX Bus", value)

func _on_ui_slider_value_changed(value: float) -> void:
	if not settings_menu.visible:
		return
	SettingsAutoload.ui_volume = value
	_apply_volume("UI Bus", value, 2.0)

## Helper function to set bus volumes
func _apply_volume(bus_name: String, value: float, max_value := 1.0) -> void:
	var bus := AudioServer.get_bus_index(bus_name)
	# Clamps the volume between a linear range of 0.0 and 1.0
	AudioServer.set_bus_volume_db(bus, linear_to_db(clampf(value, 0.0, max_value)))

func _play_audio(audio_stream: AudioStreamPlayer) -> void:
	if not audio_stream.playing:
		audio_stream.play()
		
func _tween_guard(tween: Tween) -> void:
	if tween and tween.is_running():
		tween.kill()
