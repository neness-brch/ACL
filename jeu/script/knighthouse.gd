extends Area2D

@onready var interaction_prompt = $InteractionPrompt

var player_nearby := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if not GameState.knight_house_unlocked:
		interaction_prompt.hide()
		return

	if player_nearby:
		interaction_prompt.show()

		if Input.is_action_just_pressed("interact"):
			enter_house()
	else:
		interaction_prompt.hide()


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_nearby = true


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_nearby = false


func enter_house() -> void:
	var players = get_overlapping_bodies().filter(
		func(body): return body is Player
	)

	if players.is_empty():
		return

	GameState.player_return_position = players[0].global_position
	GameState.has_return_position = true

	GameState.knight_has_moved_to_house = true

	SceneTransition.change_scene("res://scenes/knighthouse.tscn")
