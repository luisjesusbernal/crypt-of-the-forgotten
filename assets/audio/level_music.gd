extends Node

@export var music: AudioStream


func _ready() -> void:
	MusicManager.play_music(music)
