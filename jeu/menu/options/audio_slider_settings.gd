extends Control

@onready var audio_name: Label = $HBoxContainer/Audio_Name
@onready var audio_number: Label = $HBoxContainer/Audio_Number
@onready var h_slider: HSlider = $HBoxContainer/HSlider


func _ready():
	h_slider.value_changed.connect(_on_slider_changed)


func _on_slider_changed(value: float):
	Music.set_music_volume(value)
	audio_number.text = str(round(value * 100)) + "%"
