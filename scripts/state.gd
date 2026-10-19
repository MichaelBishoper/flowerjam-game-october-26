class_name State extends Node

@export var bob_frequency := 4.0
@export var bob_amplitude := 3.0
@export var bob_offset := 0.0

signal finished(next_state_path: String, data: Dictionary)

func handle_input(_event: InputEvent) -> void:
	pass
	
func update(_delta: float) -> void:
	pass
	
func physics_update(_delta: float) -> void:
	pass
	
func enter(previous_state_path: String, data := {}) -> void:
	pass

func exit() -> void:
	pass
