extends Area2D

var player_nearby := false

@onready var interaction_prompt = $InteractionPrompt
 

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	if player_nearby:
		interaction_prompt.show()
		if Input.is_action_just_pressed("interact"):
			right_way()
	else :
		interaction_prompt.hide()
		
func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_nearby = true


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_nearby = false


func right_way() -> void:
	var player = get_overlapping_bodies().filter(
		func(body): return body is Player
	)
	if player.is_empty():
		return
		
	GameState.player_return_position = player[0].global_position
	GameState.has_return_position = true

	SceneTransition.change_scene("res://scenes/foret2.tscn")
