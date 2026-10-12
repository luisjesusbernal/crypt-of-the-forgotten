extends Node

const DEFAULT_VOLUME_DB: float = -8.0
const SILENT_VOLUME_DB: float = -40.0
const FADE_DURATION: float = 0.6

@onready var music_player: AudioStreamPlayer = $MusicPlayer

var fade_tween: Tween


func play_music(music: AudioStream) -> void:
	if music == null:
		return

	# Si ya está sonando esta misma canción, no reiniciarla.
	if music_player.stream == music and music_player.playing:
		return

	if fade_tween != null and fade_tween.is_valid():
		fade_tween.kill()

	# Si ya hay música, primero bajarla.
	if music_player.playing:
		fade_tween = create_tween()
		fade_tween.tween_property(
			music_player,
			"volume_db",
			SILENT_VOLUME_DB,
			FADE_DURATION
		)
		fade_tween.tween_callback(
			Callable(self, "_switch_music").bind(music)
		)
	else:
		_switch_music(music)


func _switch_music(music: AudioStream) -> void:
	music_player.stream = music
	music_player.volume_db = SILENT_VOLUME_DB
	music_player.play()

	fade_tween = create_tween()
	fade_tween.tween_property(
		music_player,
		"volume_db",
		DEFAULT_VOLUME_DB,
		FADE_DURATION
	)


func stop_music() -> void:
	if not music_player.playing:
		return

	if fade_tween != null and fade_tween.is_valid():
		fade_tween.kill()

	fade_tween = create_tween()
	fade_tween.tween_property(
		music_player,
		"volume_db",
		SILENT_VOLUME_DB,
		FADE_DURATION
	)
	fade_tween.tween_callback(
		Callable(self, "_finish_stop")
	)


func _finish_stop() -> void:
	music_player.stop()
	music_player.stream = null
	music_player.volume_db = DEFAULT_VOLUME_DB
