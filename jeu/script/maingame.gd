extends Node2D

@onready var player: Player = $Player


func _ready():
	if GameState.has_pending_spawn:
		player.global_position = GameState.consume_spawn_position()
	elif GameState.spawn != "" :
		player.global_position = get_node(GameState.spawn).global_position
		GameState.has_return_position = false
	elif GameState.has_return_position:
		player.global_position = GameState.return_position
		GameState.has_return_position = false
	GameState.spawn = ""



func _on_texture_button_menu_pressed() -> void:
	SceneTransition.change_scene("res://menu/main_menu.tscn")

func _on_texture_button_inventory_pressed() -> void:
	GameState.return_position = player.global_position
	GameState.has_return_position = true
	SceneTransition.change_scene("res://menu/inventory.tscn")
