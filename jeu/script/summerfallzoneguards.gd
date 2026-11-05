extends Area2D

var player_nearby := false

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
	{"text": "oh, you're the one who was staying with the former Royal Guard, aren't you ?", "speaker": "guard_1"},
	{"text": "I see... so he finally decided to help someone.", "speaker": "guard_2"},
	{"text": "it's getting late. You should get some rest.", "speaker": "guard_1"},
]


# Dialogue le lendemain matin
var morning_dialogue: Array[Dictionary] = [
	{"text": "good morning !", "speaker": "guard_1"},
	{"text": "you're heading to the Summer Zone, aren't you ?", "speaker": "guard_2"},
	{"text": "well, I suppose you already have everything you need.", "speaker": "guard_1"},
]


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


func _process(_delta: float) -> void:
	if player_nearby \
	and Input.is_action_just_pressed("interact") \
	and not dialogue_box.dialogue_active:
		start_dialogue()


func start_dialogue() -> void:
	interaction_prompt.hide()

	var selected_dialogue: Array[Dictionary] = get_current_dialogue()
	var prepared_dialogue := prepare_dialogue(selected_dialogue)

	dialogue_box.start_dialogue(prepared_dialogue)


func get_current_dialogue() -> Array[Dictionary]:

	# Le chevalier a terminé son dialogue et il fait encore nuit
	if GameState.knight_house_dialogue_seen \
	and GameState.time_progress >= 3.0 \
	and not GameState.has_seen_dialogue("summer_guard_night"):

		GameState.mark_dialogue_seen("summer_guard_night")
		return night_dialogue

	# Le joueur a dormi : c'est le lendemain matin
	if GameState.knight_house_dialogue_seen \
	and GameState.has_seen_dialogue("summer_guard_night") \
	and GameState.time_progress == 0.0 \
	and not GameState.has_seen_dialogue("summer_guard_morning"):

		GameState.mark_dialogue_seen("summer_guard_morning")
		return morning_dialogue

	return dialogue


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
