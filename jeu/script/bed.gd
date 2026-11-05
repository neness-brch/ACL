
extends Area2D

var player_nearby := false

@onready var interaction_prompt = $InteractionPrompt


func _ready() -> void:
	interaction_prompt.hide()

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_nearby = true
		update_prompt()


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_nearby = false
		update_prompt()


func _process(_delta: float) -> void:
	if not player_nearby:
		return

	if not GameState.knight_house_dialogue_seen:
		return

	if Input.is_action_just_pressed("interact"):
		sleep()


func update_prompt() -> void:
	interaction_prompt.visible = (
		player_nearby
		and GameState.knight_house_dialogue_seen
	)


func sleep() -> void:
	if not GameState.knight_house_dialogue_seen:
		return

	# Passage au lendemain matin
	GameState.sleep_until_morning()

	# Recharge de la maison avec la transition
	SceneTransition.change_scene("res://knighthouse.tscn")
