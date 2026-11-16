extends Control

@onready var option_button: OptionButton = $HBoxContainer/OptionButton

const WINDOW_MODE_ARRAY : Array[String] = [
	"Full-screen",
	"Window Mode",
	"Borderless Window",
	"Borderless Full-screen"
]

func _ready():
	option_button.item_selected.connect(on_window_mode_selected)
	
func on_window_mode_selected(index : int) -> void:
	pass
