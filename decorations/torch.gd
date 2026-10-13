extends Node2D

@export var base_energy: float = 0.8
@export var flicker_amount: float = 0.15
@export var flicker_speed: float = 8.0

@onready var torch_light: PointLight2D = $TorchLight

var time_passed: float = 0.0


func _process(delta: float) -> void:
	time_passed += delta
	
	var flicker := sin(time_passed * flicker_speed) * flicker_amount
	torch_light.energy = base_energy + flicker
