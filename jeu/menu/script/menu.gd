extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_texture_button_play_pressed() -> void:
	SceneTransition.change_scene("res://maingame.tscn")


func _on_texture_button_options_pressed() -> void:
	get_tree().change_scene("res://menu/options.tscn")


func _on_texture_button_quit_pressed() -> void:
	get_tree().quit(0)
