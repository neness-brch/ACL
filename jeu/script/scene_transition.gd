extends CanvasLayer

@onready var fade: ColorRect = $Fade

@export var fade_duration: float = 0.5

var transitioning := false


func _ready():
	# On commence transparent
	fade.modulate.a = 0.0


func change_scene(scene_path: String):
	if transitioning:
		return

	transitioning = true

	# Fondu → noir
	var tween := create_tween()
	tween.tween_property(
		fade,
		"modulate:a",
		1.0,
		fade_duration
	)

	await tween.finished

	# Changement de scène
	get_tree().change_scene_to_file(scene_path)

	# Fondu noir → transparent
	var tween_out := create_tween()
	tween_out.tween_property(
		fade,
		"modulate:a",
		0.0,
		fade_duration
	)

	await tween_out.finished

	transitioning = false
