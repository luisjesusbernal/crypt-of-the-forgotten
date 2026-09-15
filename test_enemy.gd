extends CharacterBody2D

var health = 3
@onready var damage_cooldown: Timer = $DamageCooldown

func take_damage(amount: int) -> void:
	health -= amount
	print("Vida del enemigo: ", health)

	if health <= 0:
		queue_free()


func _on_damage_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and damage_cooldown.is_stopped():
		if body.has_method("take_damage"):
			body.take_damage(1, global_position)
			damage_cooldown.start()
