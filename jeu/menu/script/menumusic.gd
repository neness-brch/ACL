extends AudioStreamPlayer2D

@export var fade_duration: float = 1.0

@export var play_button: BaseButton
@export var options_button: BaseButton

func _ready() -> void:
	if play_button:
		play_button.pressed.connect(_on_play_pressed)
	if options_button:
		options_button.pressed.connect(_on_options_pressed)

func fade_out_and_stop() -> void:
	
	var tween = create_tween()
	var start_vol = volume_db
	tween.tween_property(self, "volume_db", -80.0, fade_duration).from(start_vol)
	
	tween.finished.connect(func():
		stop()
		volume_db = 0.0
	)

func _on_play_pressed() -> void:
	fade_out_and_stop()

func _on_options_pressed() -> void:
	fade_out_and_stop()
