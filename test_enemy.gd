extends CharacterBody2D

var health = 3


func take_damage(amount: int) -> void:
	health -= amount
	print("Vida del enemigo: ", health)

	if health <= 0:
		queue_free()
