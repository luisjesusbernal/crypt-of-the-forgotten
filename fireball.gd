extends Area2D

const SPEED = 500.0

var direction = 1.0


func _physics_process(delta: float) -> void:
	position.x += SPEED * direction * delta


func _on_body_entered(body: Node2D) -> void:
	# Las bolas de fuego del jugador no afectan al propio jugador.
	if body.is_in_group("player"):
		return

	# Si golpea a un enemigo, le hace daño.
	if body.is_in_group("enemy") and body.has_method("take_damage"):
		body.take_damage(1)

	# Si golpea enemigo, suelo, pared, etc., desaparece.
	queue_free()
