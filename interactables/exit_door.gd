extends Area2D

@export_file("*.tscn") var next_scene: String = ""

@onready var prompt: Label = $Label
@onready var door_visual: AnimatedSprite2D = $DoorVisual

var player_inside: bool = false
var is_opening: bool = false


func _ready() -> void:
	prompt.visible = false
	door_visual.animation = "open"
	door_visual.stop()
	door_visual.frame = 0


func _process(_delta: float) -> void:
	if player_inside and Input.is_action_just_pressed("interact") and not is_opening:
		_start_opening()


func _start_opening() -> void:
	
	is_opening = true
	prompt.visible = false
	door_visual.frame = 0
	door_visual.play("open")
	
	print("PUERTA ACTIVADA")


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = true

		if not is_opening:
			prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = false
		prompt.visible = false


func _on_door_visual_animation_finished() -> void:
	if door_visual.animation != "open" or not is_opening:
		return

	if next_scene.is_empty():
		print("ExitDoor: no hay una escena asignada en Next Scene.")
		is_opening = false
		return

	GameState.has_checkpoint = false
	GameState.checkpoint_position = Vector2.ZERO
	GameState.checkpoint_scene = ""

	get_tree().change_scene_to_file(next_scene)
