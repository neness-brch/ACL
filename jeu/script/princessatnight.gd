
extends Area2D

@export_group("Fade")
@export var fade_distance: float = 150.0
@export var full_visibility_distance: float = 550.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var player: Node2D = $"../Player"
@export_group("Music Distortion")
@export_range(0.0, 1.0) var max_distortion: float = 0.45
@export var distortion_speed: float = 1.5

var distortion_effect: AudioEffectDistortion = null


func _ready() -> void:
	sprite.modulate = Color(1, 1, 1, 0)

	var bus_index := AudioServer.get_bus_index("PrincessNight")

	if bus_index == -1:
		return

	for i in range(AudioServer.get_bus_effect_count(bus_index)):
		var effect = AudioServer.get_bus_effect(bus_index, i)

		if effect is AudioEffectDistortion:
			distortion_effect = effect
			break



func _process(delta: float) -> void:

	if GameState.time_progress < 3.0:
		sprite.visible = false
		update_distortion(0.0, delta)
		return

	if player == null:
		update_distortion(0.0, delta)
		return

	sprite.visible = true

	var distance: float = sprite.global_position.distance_to(player.global_position)

	var alpha: float = inverse_lerp(
		fade_distance,
		full_visibility_distance,
		distance
	)

	alpha = clampf(alpha, 0.0, 1.0)

	sprite.modulate = Color(1, 1, 1, alpha)

	var distortion_intensity: float = (1.0 - alpha) * max_distortion

	update_distortion(distortion_intensity, delta)
	
func update_distortion(target: float, delta: float) -> void:

	if distortion_effect == null:
		return

	distortion_effect.drive = move_toward(
		distortion_effect.drive,
		target,
		distortion_speed * delta
	)
