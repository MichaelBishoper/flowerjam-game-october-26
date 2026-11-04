class_name Room extends Node2D

@onready var room_transition: RoomTransition = $RoomTransition
## NOTE: Don't rename this please. Use this for the floors/bases NOT decorations/backgrounds
@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var area_2d: Area2D = $TileMapLayer/Area2D
@onready var collision_shape_2d: CollisionShape2D = $TileMapLayer/Area2D/CollisionShape2D
@export var level_title: Label
@export var target_room: Room
@export var entrance: Area2D
@export var exit: Area2D

## entrance's child
var anim: AnimatedSprite2D
## Reference to the player node
var player: Player
## Reference to the plaer state machine. Do state_machine.state.name to get a String of the current state.
var state_machine: StateMachine
## Contains the room's limits, determined by its Area2D
var _limits: Rect2
## Room finished status, used for game over logic
var is_completed: bool = false
## Reference to the restart button
var restart: Button

# Room Logic
var is_current_room: bool = false
var _is_door_closed: bool = false
## Detects if player is colliding with the Area2D of the room
var _player_inside := false
## For [b]one time[/b] room execution logic, currently used for the entrance closing animation
var _player_just_entered := false
## Stores the initial positions of the hauntables
var _initial_positions: Dictionary = {}
## The title of the level. Ex: Level 1 - Learning the Ropes
@export var level_title_text: String = ""
## Getter for room limits
func get_limits() -> Rect2:
	return _limits
	
# --- Private Functions --- #

func _ready() -> void:
	# Get the player node
	player = get_tree().get_first_node_in_group("player")
	# get the state machine reference
	state_machine = player.state_machine
	# Get the restart button reference
	restart = player.get_node("UI/Restart")
	# Assign the Area2D's limits to _limits
	_limits = _get_room_limits()
	# Connect native Area2D signal to local function 
	area_2d.body_entered.connect(_on_body_entered)
	# Connect native Area2D signal to local function 
	area_2d.body_exited.connect(_on_body_exited)
	# Conect native Area2D signals to local functions (for exit)
	exit.body_entered.connect(_on_exit_body_entered)
	exit.body_exited.connect(_on_exit_body_exited)
	# Grab a reference to exit's animatedsprite2d child
	anim = entrance.get_node("AnimatedSprite2D")
	# Connect the restart's pressed signal to local function
	if not restart.pressed.is_connected(_restore_initial_position):
		restart.pressed.connect(_restore_initial_position)
	# Set label title to not visible
	level_title.visible = false

func _process(delta: float) -> void:
	if _player_just_entered:
		level_title.text = level_title_text
		level_title.typewrite(level_title.text)
		_is_door_closed = false
		anim.play("door_idle_open")
		_player_just_entered = false

func _unhandled_input(event: InputEvent) -> void:
	# If player moves then door animation plays ONCE
	if ((Input.is_action_just_pressed("move_right") or 
		Input.is_action_just_pressed("move_left") or
		Input.is_action_just_pressed("move_up") or 
		Input.is_action_just_pressed("move_down")) and not _is_door_closed):
		anim.play("door_swing_close")
		await anim.animation_finished
		anim.play("door_idle_close")
		_is_door_closed = true
	# If player is in selecting or haunting state then don't restart
	if (Input.is_action_just_pressed("restart") and _player_inside 
		and state_machine.state.name != "Selecting" 
		and state_machine.state.name != "Haunting"
		and not get_tree().paused):
		_restore_initial_position()

# RESTORE AND STORE POSITIONS FUNCTIONS FOR REWIND
## Store the initial position of the player and the hauntables, it is called in the callback when the player enters the room.
func _store_initial_positions() -> void:
	if not _player_inside: 
		return
	_initial_positions.clear()
	for h in find_children("*", "Hauntable", true, false):
		_initial_positions[h] = h.global_position

## Restores the initial position of the hauntable and teleports the player to the entrance
func _restore_initial_position() -> void:
	if not _player_inside: 
		return
	player.global_position = entrance.global_position
	for node: Hauntable in _initial_positions:
		if node is not Hauntable:
			return
		var init_pos = _initial_positions[node]
		var body = node.rigid_body_2d
		body.freeze = true
		body.linear_velocity = Vector2.ZERO
		body.angular_velocity = 0.0
		var t := Transform2D(0.0, init_pos)
		PhysicsServer2D.body_set_state(
			body.get_rid(),
			PhysicsServer2D.BODY_STATE_TRANSFORM,
			t
		)
		body.freeze = false
		
# NOTE: Don't add wonky or janky rooms that can't neatly fit in a box please
## Get a rect2 of the tilemaplayer tileset, defined by the Area2D's CollisionShape2D under it
func _get_room_limits() -> Rect2:
	if collision_shape_2d is CollisionShape2D:
		var shape := collision_shape_2d.shape
		if shape is RectangleShape2D:
			var size: Vector2 = shape.size
			var center: Vector2 = collision_shape_2d.global_position
			return Rect2(center - size * 0.5, size)
			
	# If no collision shape defined use tilemap
	var used_rect := tile_map_layer.get_used_rect()
	var tile_size := tile_map_layer.tile_set.tile_size
	return Rect2(used_rect.position * tile_size, used_rect.size * tile_size)

# Called when area2d detects player
# Chain: Area2D -> room.gd
func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	_player_inside = true
	_player_just_entered = true
	# Store the initial positions
	_store_initial_positions()
	# Grab a reference to the camera
	var camera := body.get_viewport().get_camera_2d()
	print(camera)
	# Early return and warn if camera doesn't exist
	if camera == null: 
		push_warning("No active Camera2D found.")
		return
	camera.set_room_limits(_limits)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		
		_player_inside = false
		restart.pressed.disconnect(_restore_initial_position)

# Fires when player enters the exit
func _on_exit_body_entered(body: Node2D) -> void:
	if target_room:
		restart.disabled = true
		is_completed = true
		# Emit global signal to show when transitions occur
		TransitionsAutoload.transition_started.emit()
		player.fade_player(false)
		# Get the animatedsprite2d reference
		var anim = exit.get_node("AnimatedSprite2D") as AnimatedSprite2D
		anim.play("door_swing_close")
		await anim.animation_finished
		anim.play("door_idle_close")
		# Play room transition animation
		await room_transition.transition_enter()
		var spawn_point := target_room.entrance.global_position
		player.global_position = spawn_point
		await get_tree().create_timer(0.4).timeout
		player.fade_player(true)
		TransitionsAutoload.transition_finished.emit()
		await room_transition.transition_exit()
		# Conclude the signal
	else:
		print("Game Complete")
		return

func _on_exit_body_exited(body: Node2D) -> void:
	restart.disabled = false
