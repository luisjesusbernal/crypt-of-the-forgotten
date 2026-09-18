extends CanvasLayer

@onready var player = $"../Player"
@onready var mana_bar: ProgressBar = $ManaBar
@onready var health_label: Label = $HealthLabel
@onready var death_screen: ColorRect = $DeathScreen
@onready var pause_screen: ColorRect = $PauseScreen
@onready var mana_segments: HBoxContainer = $ManaSegments

const MANA_PER_SEGMENT: float = 20.0

var mana_segment_nodes: Array[ProgressBar] = []
var last_mana_segment_count: int = -1

func _ready() -> void:
	mana_bar.max_value = player.max_mana
	mana_bar.value = player.mana
	death_screen.visible = false
	pause_screen.visible = false
	
func _process(_delta: float) -> void:
	mana_bar.max_value = player.max_mana
	mana_bar.value = player.mana
	_update_mana_segments()
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
	
func _update_mana_segments() -> void:
	var segment_count := int(ceil(player.max_mana / MANA_PER_SEGMENT))

	if segment_count != last_mana_segment_count:
		for child in mana_segments.get_children():
			child.queue_free()

		mana_segment_nodes.clear()

		for i in range(segment_count):
			var segment := ProgressBar.new()

			segment.min_value = 0.0
			segment.max_value = MANA_PER_SEGMENT
			segment.show_percentage = false
			segment.custom_minimum_size = Vector2(24, 14)

			var bg_style := StyleBoxFlat.new()
			bg_style.bg_color = Color("1f2933")
			bg_style.border_width_left = 1
			bg_style.border_width_top = 1
			bg_style.border_width_right = 1
			bg_style.border_width_bottom = 1
			bg_style.border_color = Color("0b1220")
			bg_style.corner_radius_top_left = 2
			bg_style.corner_radius_top_right = 2
			bg_style.corner_radius_bottom_left = 2
			bg_style.corner_radius_bottom_right = 2

			var fill_style := StyleBoxFlat.new()
			fill_style.bg_color = Color("49a6ff")
			fill_style.corner_radius_top_left = 2
			fill_style.corner_radius_top_right = 2
			fill_style.corner_radius_bottom_left = 2
			fill_style.corner_radius_bottom_right = 2

			segment.add_theme_stylebox_override("background", bg_style)
			segment.add_theme_stylebox_override("fill", fill_style)

			mana_segments.add_child(segment)
			mana_segment_nodes.append(segment)

		last_mana_segment_count = segment_count

	for i in range(mana_segment_nodes.size()):
		mana_segment_nodes[i].value = clampf(
			player.mana - (i * MANA_PER_SEGMENT),
			0.0,
			MANA_PER_SEGMENT
		)
