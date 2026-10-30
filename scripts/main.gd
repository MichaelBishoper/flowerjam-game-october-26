extends Node2D

@onready var dim_overlay: CanvasLayer = $DimOverlay
@onready var player: Player = $Player

func _ready() -> void:
	# Hide the dim overlay for selecting mode
	dim_overlay.hide()
	
	# Connect the global signal autoloads to local function
	TransitionsAutoload.transition_started.connect(_on_transition_started)
	TransitionsAutoload.transition_finished.connect(_on_transition_finished)

func _on_transition_started() -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(-5.00))
	player.set_physics_process(false)
	
func _on_transition_finished() -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),0.00)
	player.set_physics_process(true)
