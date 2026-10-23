class_name Trapdoor extends Node2D

@onready var trapdoor: RigidBody2D = $Trapdoor

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("debug_button_1"):
		print("Hi")
		trapdoor.apply_torque_impulse(-500.0)
	
