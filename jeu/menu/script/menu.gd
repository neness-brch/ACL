extends Control
const MusicData = preload("res://MusicData.gd")
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $"../AudioStreamPlayer2D"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audio_stream_player_2d.play(MusicData.music_position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_texture_button_play_pressed() -> void:
	MusicData.music_position = 0.0
	SceneTransition.change_scene("res://maingame.tscn")


func _on_texture_button_options_pressed() -> void:
	MusicData.music_position = audio_stream_player_2d.get_playback_position()
	SceneTransition.change_scene("res://menu/options.tscn")


func _on_texture_button_quit_pressed() -> void:
	get_tree().quit(0)


func playpressed() -> void:
	pass # Replace with function body.
