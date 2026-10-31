extends Button

@export var settings_click: AudioStreamPlayer
@onready var in_game_menu: CanvasLayer = $"../../InGameMenu"
@onready var settings_hover: AudioStreamPlayer = $"../../SettingsHover"
@onready var restart: Button = $"../Restart"

func _ready() -> void:
	pressed.connect(_on_button_pressed)
	mouse_entered.connect(_on_mouse_entered)

func _on_button_pressed() -> void:
	# Opening the menu
	if in_game_menu.visible == false:
		in_game_menu.visible = true
		get_tree().paused = true
		restart.disabled = true
	# Closing the menu
	else:
		in_game_menu.visible = false
		get_tree().paused = false
		restart.disabled = false
	settings_click.play()

func _on_mouse_entered() -> void:
	settings_hover.play()
