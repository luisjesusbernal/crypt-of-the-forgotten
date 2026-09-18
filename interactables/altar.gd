extends Area2D

@onready var prompt: Label = $Label
@onready var upgrade_panel: PanelContainer = $UpgradePanel
@onready var active_visual: AnimatedSprite2D = $ActiveVisual
@onready var used_visual: AnimatedSprite2D = $UsedVisual

var player_inside: bool = false
var player: Node2D = null
var upgrade_open: bool = false
@export var altar_id: String = "level1_altar_1"

func _ready() -> void:
	prompt.visible = false
	upgrade_panel.visible = false
	_update_altar_visual()


func _process(_delta: float) -> void:
	if player_inside and Input.is_action_just_pressed("interact") and not upgrade_open:
		if player != null and player.has_method("heal_full"):
			player.heal_full()

			GameState.has_checkpoint = true
			GameState.checkpoint_position = player.global_position
			GameState.checkpoint_scene = get_tree().current_scene.scene_file_path

			if _blessing_already_chosen():
				prompt.text = "E - Descansar"
				prompt.visible = true
			else:
				upgrade_panel.visible = true
				prompt.visible = false
				upgrade_open = true

			print("ALTAR ACTIVADO")
			print("Checkpoint guardado en: ", GameState.checkpoint_position)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		player_inside = true

		if not upgrade_open:
			prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = false
		player = null
		prompt.visible = false
		upgrade_panel.visible = false
		upgrade_open = false


func _on_health_button_pressed() -> void:
	if player == null or _blessing_already_chosen():
		return

	GameState.max_health_bonus += 1
	GameState.used_altars[altar_id] = true
	_update_altar_visual()

	player.max_health += 1
	player.health = player.max_health

	upgrade_panel.visible = false
	upgrade_open = false

	prompt.text = "E - Descansar"
	prompt.visible = true


func _on_mana_button_pressed() -> void:
	if player == null or _blessing_already_chosen():
		return

	GameState.max_mana_bonus += 20.0
	GameState.used_altars[altar_id] = true
	_update_altar_visual()
	
	player.max_mana += 20.0
	player.mana = player.max_mana

	upgrade_panel.visible = false
	upgrade_open = false

	prompt.text = "E - Descansar"
	prompt.visible = true
	
	
func _blessing_already_chosen() -> bool:
	return GameState.used_altars.has(altar_id)
	
func _update_altar_visual() -> void:
	if _blessing_already_chosen():
		active_visual.visible = false
		active_visual.stop()

		used_visual.visible = true
		used_visual.play("used")

		prompt.text = "E - Descansar"
	else:
		active_visual.visible = true
		active_visual.play("idle")

		used_visual.visible = false
		used_visual.stop()

		prompt.text = "E - Usar altar"
