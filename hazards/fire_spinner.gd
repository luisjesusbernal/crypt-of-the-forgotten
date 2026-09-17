extends Node2D

@export var rotation_speed: float = 120.0
@export var damage: int = 1

@onready var rotator: Node2D = $Rotator


func _process(delta: float) -> void:
	rotator.rotation += deg_to_rad(rotation_speed) * delta


func _on_damage_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage, global_position)
