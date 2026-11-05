extends CanvasLayer

@export var lullabye: AudioStreamPlayer
@export var video_stream_player: VideoStreamPlayer

func _ready() -> void:
	if not lullabye.playing:
		lullabye.play()
	await video_stream_player.finished
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
