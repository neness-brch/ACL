extends Node2D

@onready var player: Player = $Player

func _ready():
	if GameState.has_return_position:
		player.global_position = GameState.return_position

		print("POSITION RESTAUREE : ", GameState.return_position)

		GameState.has_return_position = false


func _on_texture_button_menu_pressed() -> void:
	SceneTransition.change_scene("res://menu/main_menu.tscn")
