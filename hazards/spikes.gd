extends Area2D

@export var instant_kill: bool = false
@export var damage: int = 1


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	if instant_kill:
		if body.has_method("die"):
			body.die()
	else:
		if body.has_method("take_damage"):
			body.take_damage(damage, global_position)
