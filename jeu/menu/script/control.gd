
extends Control
const MusicData = preload("res://MusicData.gd")
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $"../AudioStreamPlayer2D"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audio_stream_player_2d.play(MusicData.music_position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_texture_button_pressed() -> void:
	MusicData.music_position = audio_stream_player_2d.get_playback_position()
	SceneTransition.change_scene("res://menu/main_menu.tscn")
