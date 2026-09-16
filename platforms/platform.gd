@tool
extends StaticBody2D

@export_range(64.0, 1000.0, 1.0) var width: float = 300.0:
	set(value):
		width = value
		_update_platform()


func _ready() -> void:
	# Cada instancia tendrá su propio collider.
	var collision_shape := get_node_or_null("CollisionShape2D") as CollisionShape2D

	if collision_shape != null and collision_shape.shape != null:
		collision_shape.shape = collision_shape.shape.duplicate()

	_update_platform()


func _update_platform() -> void:
	var collision_shape := get_node_or_null("CollisionShape2D") as CollisionShape2D
	var platform_sprite := get_node_or_null("Sprite2D") as Sprite2D

	# Cambiar ancho del collider.
	if collision_shape != null and collision_shape.shape is RectangleShape2D:
		var rectangle := collision_shape.shape as RectangleShape2D
		rectangle.size.x = width

	# Cambiar ancho de la textura repetida.
	if platform_sprite != null:
		var rect := platform_sprite.region_rect
		rect.size.x = width
		platform_sprite.region_rect = rect
