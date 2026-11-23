extends Area2D

@export var monster_id: String = "monster_2"

@onready var monster: AnimatedSprite2D = $AnimatedSprite2D
@onready var player: Player = $"../Player"
@onready var interaction_prompt: Control = $InteractionPrompt

var player_nearby: bool = false
var battle_started: bool = false


func _ready() -> void:
	interaction_prompt.hide()

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if GameState.is_monster_defeated(monster_id):
		monster.hide()
		monster.process_mode = Node.PROCESS_MODE_DISABLED


	else:
		# Le monstre bloque le passage tant qu'il est vivant.
		create_obstacle(
			"MonsterObstacle",
			monster.position,
			Vector2(60, 60)
		)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body
		player_nearby = true
		update_interaction_prompt()


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_nearby = false
		interaction_prompt.hide()


func _process(_delta: float) -> void:
	if player_nearby \
	and not battle_started \
	and Input.is_action_just_pressed("interact") \
	and not GameState.is_monster_defeated(monster_id) \
	and GameState.is_quest_active("summer_quest"):
		start_battle()


func update_interaction_prompt() -> void:
	interaction_prompt.visible = (
		player_nearby
		and not battle_started
		and GameState.is_quest_active("summer_quest")
		and not GameState.is_monster_defeated(monster_id)
	)


func start_battle() -> void:
	if battle_started:
		return

	battle_started = true
	interaction_prompt.hide()

	# Sauvegarder la position du joueur.
	GameState.save_return_position(player.global_position)

	# Débloquer l'attaque spéciale.
	if not GameState.unlocked_attacks.has("special_attack"):
		GameState.unlocked_attacks.append("special_attack")

	# Lancer le combat.
	SceneTransition.change_scene("res://scenes/battle3.tscn")


func create_obstacle(
	obstacle_name: String,
	obstacle_position: Vector2,
	obstacle_size: Vector2
) -> void:
	var body := StaticBody2D.new()
	body.name = obstacle_name
	body.position = obstacle_position
	body.collision_layer = 1
	body.collision_mask = 0

	var collision := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = obstacle_size
	collision.shape = rectangle

	body.add_child(collision)
	add_child(body)


func _on_quest_active_changed(quest_id: String, _active: bool) -> void:
	if quest_id == "summer_quest":
		update_interaction_prompt()
