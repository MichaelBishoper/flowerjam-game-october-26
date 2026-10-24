extends Node2D

@onready var dim_overlay: CanvasLayer = $DimOverlay

func _ready() -> void:
	dim_overlay.hide()
