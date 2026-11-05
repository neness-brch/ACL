extends Area2D

var player_nearby := false
var current_dialogue_id: String = ""

@onready var interaction_prompt = $InteractionPrompt
@onready var dialogue_box: DialogueBox = $"../CanvasLayer/BoiteDialogues"

@export var guard_1_portrait: Texture2D
@export var guard_2_portrait: Texture2D


# Dialogue normal
var dialogue: Array[Dictionary] = [
	{"text": "we are the proud guards of the Summer/Fall Zone Gate !", "speaker": "guard_1"},
	{"text": "do you have a special pass ?", "speaker": "guard_2"},
	{"text": "...doesn't seem so", "speaker": "guard_2"},
	{"text": "therefore, you are not allowed to pass the gate", "speaker": "guard_2"},
	{"text": "sorry, these are the rules !", "speaker": "guard_1"},
]


# Dialogue pendant la nuit, après la conversation avec le chevalier
var night_dialogue: Array[Dictionary] = [
	{"text": "zzzzzzzzzzzz", "speaker": "guard_1"},
	{"text": "what a day...", "speaker": "guard_1"},
	{"text": "sorry, the gate is closed until next morning !", "speaker": "guard_1"},
	{"text": "come back later ! I mean...only if you have a Special Pass of course.", "speaker": "guard_2"},
	{"text": "who wants to go to the Winter Zone anyway ?", "speaker": "guard_1"},
	{"text": "everything is quite dead there.", "speaker": "guard_1"}
]


var morning_dialogue: Array[Dictionary] = [
	{"text": "we are the proud guards of the Summer/Fall Zone Gate !", "speaker": "guard_1"},
	{"text": "do you have a special pass ?", "speaker": "guard_2"},
	{"text": "...looks like it !", "speaker": "guard_2"},
	{"text": "have a great time there !", "speaker": "guard_2"}
]


var repeat_dialogue: Array[Dictionary] = [
	{"text": "everything is in order. You may pass.", "speaker": "guard_1"},
]


func _ready() -> void:
	interaction_prompt.hide()

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_nearby = true
		interaction_prompt.show()


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_nearby = false
		interaction_prompt.hide()


func _process(_delta: float) -> void:
	if player_nearby \
	and Input.is_action_just_pressed("interact") \
	and not dialogue_box.dialogue_active:
		start_dialogue()


func start_dialogue() -> void:
	interaction_prompt.hide()

	current_dialogue_id = get_current_dialogue_id()

	var selected_dialogue: Array[Dictionary] = get_current_dialogue()
	var prepared_dialogue := prepare_dialogue(selected_dialogue)

	dialogue_box.start_dialogue(prepared_dialogue)


func get_current_dialogue_id() -> String:

	# Event 1 pas encore fait : l'héroïne n'a pas de passe
	if not GameState.knight_house_dialogue_seen:
		return "summer_guard_normal"

	# Passe obtenu mais pas encore dormi : c'est toujours la nuit,
	# la porte reste fermée (ce dialogue se répète à chaque visite)
	if not GameState.has_slept_after_knight_dialogue:
		return "summer_guard_night"

	# Premier passage le matin : ce dialogue ouvre la porte
	if not GameState.has_seen_dialogue("summer_guard_morning"):
		return "summer_guard_morning"

	# Ensuite : la porte est ouverte
	return "summer_guard_repeat"


func get_current_dialogue() -> Array[Dictionary]:

	match current_dialogue_id:
		"summer_guard_night":
			return night_dialogue

		"summer_guard_morning":
			return morning_dialogue

		"summer_guard_repeat":
			return repeat_dialogue

		_:
			return dialogue


func _on_dialogue_finished() -> void:

	if current_dialogue_id == "summer_guard_morning":
		GameState.mark_dialogue_seen("summer_guard_morning")
		GameState.open_summer_gate()

	current_dialogue_id = ""


func prepare_dialogue(source_dialogue: Array[Dictionary]) -> Array[Dictionary]:
	var prepared: Array[Dictionary] = []

	for message in source_dialogue:
		var new_message := message.duplicate()
		var speaker: String = message.get("speaker", "")

		if speaker == "guard_1":
			new_message["portrait"] = guard_1_portrait

		elif speaker == "guard_2":
			new_message["portrait"] = guard_2_portrait

		else:
			new_message["portrait"] = null

		prepared.append(new_message)

	return prepared
