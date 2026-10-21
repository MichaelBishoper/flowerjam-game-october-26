class_name Room extends Node2D

@onready var area_2d: Area2D = $TileMapLayer/Area2D
# NOTE: Don't rename this please. Use this for the floors/bases NOT decorations/backgrounds
@onready var tile_map_layer: TileMapLayer = $TileMapLayer

var _limits: Rect2

# Getter for limits
func get_limits() -> Rect2:
	return _limits
	
	
	
# --- Private Functions --- #

func _ready() -> void:
	pass

func _get_room_limits() -> Rect2:
	var used_rect := tile_map_layer.get_used_rect()
	var tile_size := tile_map_layer.tile_set.tile_size
	var pos := used_rect.position * tile_size
	var size := used_rect.size * tile_size
	return Rect2(pos, size)

func _on_body_entered(body: Node2D) -> void:
	# TODO: Make a node group for player
	if not body.is_in_group("player"):
		return
	var camera := body.get_viewport().get_camera_2d()
	if camera == null: 
		return
	# TODO: Make set_room_limits function in the camera script
	camera.set_room_limits(_limits)	
