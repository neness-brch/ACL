extends Control

@onready var audio_number: Label = $HBoxContainer/Audio_Number
@onready var h_slider: HSlider = $HBoxContainer/HSlider

var music_bus = AudioServer.get_bus_index("Master")


func _ready():
	h_slider.min_value = 0.0
	h_slider.max_value = 1.0
	h_slider.step = 0.01

	var current_volume = db_to_linear(AudioServer.get_bus_volume_db(music_bus))

	h_slider.value = current_volume
	audio_number.text = str(round(current_volume * 100)) + "%"

	h_slider.value_changed.connect(_on_slider_changed)


func _on_slider_changed(value: float):
	if value == 0:
		AudioServer.set_bus_volume_db(music_bus, -80.0)
	else:
		AudioServer.set_bus_volume_db(music_bus, linear_to_db(value))

	audio_number.text = str(round(value * 100)) + "%"
