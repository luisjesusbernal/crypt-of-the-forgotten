extends CanvasLayer

@onready var player = $"../Player"
@onready var mana_bar: ProgressBar = $ManaBar
@onready var health_label: Label = $HealthLabel
@onready var death_screen: ColorRect = $DeathScreen
@onready var pause_screen: ColorRect = $PauseScreen

func _ready() -> void:
	mana_bar.max_value = player.max_mana
	mana_bar.value = player.mana
	death_screen.visible = false
	pause_screen.visible = false
	
func _process(_delta: float) -> void:
	mana_bar.value = player.mana

	var hearts = ""

	for i in range(player.max_health):
		if i < player.health:
			hearts += "♥ "
		else:
			hearts += "♡ "

	health_label.text = hearts
	
	if Input.is_action_just_pressed("pause") and not death_screen.visible:
		toggle_pause()

func _on_retry_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_exit_button_pressed() -> void:
	get_tree().quit()

func show_death_screen() -> void:
	death_screen.visible = true


func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	$PauseScreen.visible = false

func toggle_pause() -> void:
	var should_pause = not get_tree().paused

	get_tree().paused = should_pause
	pause_screen.visible = should_pause


func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
