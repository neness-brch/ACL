extends CanvasLayer

@export var bar_height: float = 90.0
@export var animation_duration: float = 1.5

@onready var top_bar: ColorRect = $TopBar
@onready var bottom_bar: ColorRect = $BottomBar

var animation_finished := false

func _ready() -> void:
	top_bar.size.y = 0.0
	bottom_bar.offset_top = 0.0

func show_bars() -> void:
	var tween = create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		top_bar,
		"size:y",
		bar_height,
		animation_duration
	)

	tween.tween_property(
		bottom_bar,
		"offset_top",
		-bar_height,
		animation_duration
	)

	await tween.finished
	animation_finished = true
