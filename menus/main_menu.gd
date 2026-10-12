extends Control

@export var menu_music: AudioStream


func _ready() -> void:
	MusicManager.play_music(menu_music)


func _on_new_game_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/Intro.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
