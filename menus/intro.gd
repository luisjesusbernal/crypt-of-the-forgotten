extends Control

var is_transitioning: bool = false


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		_start_game()


func _start_game() -> void:
	if is_transitioning:
		return

	is_transitioning = true
	get_tree().change_scene_to_file("res://main.tscn")
