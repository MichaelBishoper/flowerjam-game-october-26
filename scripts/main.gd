extends Node2D

@onready var dim_overlay: CanvasLayer = $DimOverlay
@onready var player: Player = $Player
@export var game_theme: AudioStreamPlayer

func _ready() -> void:
	get_tree().paused = false
	# Hide the dim overlay for selecting mode
	dim_overlay.hide()
	# Connect the global signal autoloads to local function
	TransitionsAutoload.transition_started.connect(_on_transition_started)
	TransitionsAutoload.transition_finished.connect(_on_transition_finished)
	game_theme.play()

func _on_transition_started() -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), -2.00)
	player.set_physics_process(false)
	
func _on_transition_finished() -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),0.00)
	player.set_physics_process(true)
