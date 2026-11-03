extends Area2D

var player_nearby := false
var collected := false
@onready var interaction_prompt = $InteractionPrompt

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	interaction_prompt.visible = false


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_nearby = true
		interaction_prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_nearby = false
		interaction_prompt.visible = false


func _process(_delta: float) -> void:
	if collected or not player_nearby:
		return

	if not GameState.is_quest_active("fall_quest"):
		return

	if GameState.is_quest_completed("fall_quest"):
		return

	if Input.is_action_just_pressed("interact"):
		collect_leaf()


func collect_leaf() -> void:
	if collected:
		return

	if not GameState.is_quest_active("fall_quest"):
		return

	if GameState.is_quest_completed("fall_quest"):
		return

	collected = true
	GameState.add_quest_progress("fall_quest", 1)
	queue_free()
