extends RigidBody2D

@export var object_collision: AudioStreamPlayer2D
## The threshold velocity at which a hauntable's rigidbody2d plays a sound
@export var vel_threshold: float = 200.0
var prev_velocity: Vector2 = Vector2.ZERO

func _physics_process(_delta: float) -> void:
	prev_velocity = linear_velocity

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var impact := (prev_velocity - state.linear_velocity).length()
	if state.get_contact_count() > 0 and impact > vel_threshold:
		if self.is_in_group("beach_ball"):
			print(impact)
		object_collision.play()
			
