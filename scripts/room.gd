class_name Room extends Node2D

# NOTE: Don't rename this please. Use this for the floors/bases NOT decorations/backgrounds
@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var area_2d: Area2D = $TileMapLayer/Area2D
@onready var collision_shape_2d: CollisionShape2D = $TileMapLayer/Area2D/CollisionShape2D

var _limits: Rect2

# Getter for limits
func get_limits() -> Rect2:
	return _limits
	
	
	
# --- Private Functions --- #

func _ready() -> void:
	# Assign the Area2D's limits to _limits
	_limits = _get_room_limits()
	# Connect native Area2D signal to local function 
	area_2d.body_entered.connect(_on_body_entered)

# Get a rect2 of the tilemaplayer tileset, defined by the collisionshape2d
# NOTE: Don't add wonky or janky rooms that can't neatly fit in a box please
func _get_room_limits() -> Rect2:
	if collision_shape_2d is CollisionShape2D:
		var shape := collision_shape_2d.shape
		if shape is RectangleShape2D:
			var size: Vector2 = shape.size
			var center: Vector2 = collision_shape_2d.global_position
			return Rect2(center - size * 0.5, size)
	var used_rect := tile_map_layer.get_used_rect()
	var tile_size := tile_map_layer.tile_set.tile_size
	return Rect2(used_rect.position * tile_size, used_rect.size * tile_size)

# Called when area2d detects player
# Chain: Area2D -> room.gf
func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	# Grab a reference to the camera
	var camera := body.get_viewport().get_camera_2d()
	# Early return and warn if camera doesn't exist
	if camera == null: 
		push_warning("No active Camera2D found.")
		return
	camera.set_room_limits(_limits)	
	print(_limits)
