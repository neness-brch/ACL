extends Area2D

@export var outside_spawn_position: Vector2 = Vector2(-2750, 100)

var player_nearby := false
var is_leaving := false

@onready var interaction_prompt = $InteractionPrompt


func _ready() -> void:
	interaction_prompt.hide()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_nearby = true
		interaction_prompt.show()


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_nearby = false
		interaction_prompt.hide()


func _unhandled_input(event: InputEvent) -> void:
	if player_nearby and not is_leaving and event.is_action_pressed("interact"):
		is_leaving = true
		GameState.set_spawn_point(outside_spawn_position)
		SceneTransition.change_scene("res://maingame.tscn")
