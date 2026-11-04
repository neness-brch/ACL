extends Node2D

@onready var player: Player = $Player


func _ready() -> void:
	if GameState.has_pending_spawn:
		player.global_position = GameState.consume_spawn_position()
	elif GameState.has_return_position:
		player.global_position = GameState.consume_return_position()


func _on_texture_button_menu_pressed() -> void:
	SceneTransition.change_scene("res://maingame.tscn")
