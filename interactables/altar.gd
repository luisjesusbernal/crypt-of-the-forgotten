extends Area2D

@onready var prompt: Label = $Label

var player_inside: bool = false
var player: Node2D = null


func _ready() -> void:
	prompt.visible = false


func _process(_delta: float) -> void:
	if player_inside and Input.is_action_just_pressed("interact"):
		if player != null and player.has_method("heal_full"):
			player.heal_full()

			GameState.has_checkpoint = true
			GameState.checkpoint_position = player.global_position

			print("ALTAR ACTIVADO")
			print("Checkpoint guardado en: ", GameState.checkpoint_position)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		player_inside = true
		prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = false
		player = null
		prompt.visible = false
