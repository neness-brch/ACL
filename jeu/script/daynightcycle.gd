extends CanvasModulate

const DAY_COLOR := Color(1.0, 1.0, 1.0)
const NIGHT_COLOR := Color(0.25, 0.30, 0.50)

func _ready() -> void:
	GameState.time_of_day_changed.connect(_on_time_of_day_changed)
	update_time_of_day()

func update_time_of_day() -> void:
	var progress: float = GameState.time_progress / 3.0
	color = DAY_COLOR.lerp(NIGHT_COLOR, progress)

func _on_time_of_day_changed(_progress: float) -> void:
	update_time_of_day()
