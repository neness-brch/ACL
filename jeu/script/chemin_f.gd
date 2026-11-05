extends Area2D

var player_nearby := false
@export var spawn: String = "Depart"
@onready var interaction_prompt = $InteractionPrompt
 

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	if player_nearby:
		interaction_prompt.show()
		if Input.is_action_just_pressed("interact"):
			false_way()
	else :
		interaction_prompt.hide()
		
func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_nearby = true


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_nearby = false


func false_way() -> void:
	GameState.spawn = spawn
	SceneTransition.change_scene("res://maingame.tscn")
