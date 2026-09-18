extends Node

var has_checkpoint: bool = false
var checkpoint_position: Vector2 = Vector2.ZERO
var checkpoint_scene: String = ""

var max_health_bonus: int = 0
var max_mana_bonus: float = 0.0

var used_altars: Dictionary = {}
