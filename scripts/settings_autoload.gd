extends Node

# Linear volume NOT dB
var music_volume: float = 1.0
var ui_volume: float = 2.0
var sfx_volume: float = 1.0
var tutorial_done: bool = false
# TODO: Once the drooler count is not zero then show the drooler counter
var droolers_collected: int = 0

signal drooler_collected(value: int)

func add_drooler(n: int = 1) -> void:
	droolers_collected += n
	drooler_collected.emit(n)

func remove_drooler(n: int = 1) -> void:
	droolers_collected = maxi(0, droolers_collected - n)
	drooler_collected.emit(-n)
