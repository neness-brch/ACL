
extends Area2D

@export var monster_id: String = "monster_2"

@onready var knight: Sprite2D = $Sprite2D
@onready var monster: AnimatedSprite2D = $AnimatedSprite2D
@onready var player: Player = $"../Player"
@onready var dialogue_box: DialogueBox = $"../CanvasLayer/BoiteDialogues"
@onready var interaction_prompt: Control = $InteractionPrompt
@export var knight_portrait: Texture2D
@onready var new_dialogue_bubble = $BulleDialogue

var player_nearby: bool = false
var current_dialogue_id: String = ""
var encounter_return_position: Vector2


var encounter_dialogue: Array[Dictionary] = [
	{
		"text": "help! This monster is too powerful!",
		"speaker": "knight"
	},
	{
		"text": "I've wounded it, but I can't fight anymore.",
		"speaker": "knight"
	},
	
]


func _ready() -> void:
	interaction_prompt.hide()

	# Connexion des signaux
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)

	# Restaurer l'état du chevalier et du monstre
	if GameState.is_monster_defeated(monster_id):
		monster.hide()
		monster.process_mode = Node.PROCESS_MODE_DISABLED

		# Apparence du chevalier après le combat
		knight.region_enabled = true
		knight.region_rect = Rect2(
			79.29258, 2.0749948, 234.95468, 327.84918
		)
		
	new_dialogue_bubble.hide()
	GameState.quest_active_changed.connect(_on_quest_active_changed)
	update_dialogue_bubble()

	# Collision du chevalier
	create_obstacle(
		"KnightObstacle",
		knight.position,
		Vector2(60, 30)
	)

	# Collision du monstre uniquement s'il est encore vivant
	if not GameState.is_monster_defeated(monster_id):
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
	update_interaction_prompt()

	if player_nearby \
	and Input.is_action_just_pressed("interact") \
	and not dialogue_box.dialogue_active \
	and current_dialogue_id == "" \
	and not GameState.is_monster_defeated(monster_id) \
	and GameState.is_quest_active("fall_quest") :

		start_encounter()


func update_interaction_prompt():
	interaction_prompt.visible = (
		player_nearby
		and GameState.is_quest_active("fall_quest")
		and not dialogue_box.dialogue_active
		and current_dialogue_id == ""
		and not GameState.is_monster_defeated(monster_id)
	)

func start_encounter():
	current_dialogue_id = "monster_2_encounter"

	interaction_prompt.hide()
	new_dialogue_bubble.hide()

	GameState.mark_dialogue_seen(current_dialogue_id)

	encounter_return_position = player.global_position
	dialogue_box.start_dialogue(prepare_dialogue(encounter_dialogue))


func _on_dialogue_finished() -> void:
	if current_dialogue_id != "monster_2_encounter":
		return

	current_dialogue_id = ""

	GameState.save_return_position(encounter_return_position)

	print("POSITION SAUVEGARDEE : ", encounter_return_position)

	SceneTransition.change_scene("res://scenes/battle2.tscn")


func prepare_dialogue(dialogue: Array[Dictionary]) -> Array[Dictionary]:
	var prepared: Array[Dictionary] = []

	for message in dialogue:
		var new_message := message.duplicate()
		var speaker: String = message.get("speaker", "")

		if speaker == "knight":
			new_message["portrait"] = knight_portrait

		else:
			new_message["portrait"] = null

		prepared.append(new_message)

	return prepared


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


func update_dialogue_bubble():
	new_dialogue_bubble.visible = (
		GameState.is_quest_active("fall_quest")
		and not GameState.is_monster_defeated(monster_id)
		and not GameState.has_seen_dialogue("monster_2_encounter")
	)


func _on_quest_active_changed(quest_id: String, _active: bool):
	if quest_id == "fall_quest":
		update_dialogue_bubble()
		update_interaction_prompt()
