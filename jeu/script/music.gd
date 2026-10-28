extends Node

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var silence_timer: Timer = $SilenceTimer

var tracks: Array[AudioStream] = [
	preload("res://music/secunda.ogg"),
	preload("res://music/hogre.ogg"),
	preload("res://music/tedra.ogg")
]

var last_track: AudioStream = null


func _ready():
	audio_player.finished.connect(_on_music_finished)
	silence_timer.timeout.connect(_on_silence_finished)

	play_random_track()


func play_random_track():
	if tracks.is_empty():
		return

	var available_tracks = tracks.duplicate()

	if last_track != null and available_tracks.size() > 1:
		available_tracks.erase(last_track)

	var track: AudioStream = available_tracks.pick_random()

	last_track = track
	audio_player.stream = track
	audio_player.play()


func _on_music_finished():
	silence_timer.wait_time = randf_range(20.0, 90.0)
	silence_timer.start()


func _on_silence_finished():
	play_random_track()
