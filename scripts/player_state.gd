class_name PlayerState extends State

const IDLE = "Idle"
const MOVING = "Moving"
const SELECTING = "Selecting"
const HAUnTING = "Haunting"

var player: Player

func _ready() -> void:
	await owner.ready
	# Grab the player node and set it as an object of Player for autocomplete
	player = owner as Player 
	# Remove in production 
	assert(player != null, "The PlayerState state type must be used only in the player scene. 
		It needs the owner to be a Player node.")
