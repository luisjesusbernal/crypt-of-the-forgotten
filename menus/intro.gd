extends Control

@onready var slide: TextureRect = $Slide
@onready var skip_label: Label = $SkipLabel
@onready var fade: ColorRect = $Fade

const HOLD_TO_SKIP_TIME: float = 0.7
const FADE_TIME: float = 0.25
const ZOOM_TIME: float = 6.0
const ZOOM_AMOUNT: float = 1.04

var is_transitioning: bool = false
var is_fading: bool = false
var current_index: int = 0
var hold_time: float = 0.0

var fade_tween: Tween
var zoom_tween: Tween

var slides: Array[Texture2D] = [
	preload("res://assets/intro/intro_01.png"),
	preload("res://assets/intro/intro_02.png"),
	preload("res://assets/intro/intro_03.png"),
	preload("res://assets/intro/intro_04.png"),
	preload("res://assets/intro/intro_05.png")
]


func _ready() -> void:
	slide.texture = slides[current_index]
	slide.pivot_offset = slide.size / 2.0

	fade.modulate.a = 1.0

	_start_zoom()

	fade_tween = create_tween()
	fade_tween.tween_property(
		fade,
		"modulate:a",
		0.0,
		0.5
	)


func _process(delta: float) -> void:
	if is_transitioning:
		return

	if Input.is_action_pressed("interact"):
		hold_time += delta

		if hold_time >= HOLD_TO_SKIP_TIME:
			hold_time = 0.0
			_start_game()
			return

	elif Input.is_action_just_released("interact"):
		if hold_time > 0.0 and not is_fading:
			_next_slide()

		hold_time = 0.0


func _next_slide() -> void:
	if current_index >= slides.size() - 1:
		_start_game()
		return

	is_fading = true

	if fade_tween != null and fade_tween.is_valid():
		fade_tween.kill()

	fade_tween = create_tween()
	fade_tween.tween_property(
		fade,
		"modulate:a",
		1.0,
		FADE_TIME
	)

	fade_tween.tween_callback(_change_slide)

	fade_tween.tween_property(
		fade,
		"modulate:a",
		0.0,
		FADE_TIME
	)

	fade_tween.tween_callback(_finish_fade)


func _change_slide() -> void:
	current_index += 1
	slide.texture = slides[current_index]

	skip_label.visible = current_index < slides.size() - 1

	_start_zoom()


func _finish_fade() -> void:
	is_fading = false


func _start_zoom() -> void:
	if zoom_tween != null and zoom_tween.is_valid():
		zoom_tween.kill()

	slide.scale = Vector2.ONE
	slide.pivot_offset = slide.size / 2.0

	zoom_tween = create_tween()
	zoom_tween.tween_property(
		slide,
		"scale",
		Vector2(ZOOM_AMOUNT, ZOOM_AMOUNT),
		ZOOM_TIME
	)


func _start_game() -> void:
	if is_transitioning:
		return

	is_transitioning = true

	if fade_tween != null and fade_tween.is_valid():
		fade_tween.kill()

	fade_tween = create_tween()
	fade_tween.tween_property(
		fade,
		"modulate:a",
		1.0,
		0.4
	)

	fade_tween.tween_callback(
		func():
			get_tree().change_scene_to_file("res://main.tscn")
	)
