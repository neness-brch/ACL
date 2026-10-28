extends Area2D

var player_nearby := false

@onready var interaction_prompt = $InteractionPrompt
@onready var dialogue_box: DialogueBox = $"../CanvasLayer/BoiteDialogues"

@export var guard_1_portrait: Texture2D
@export var guard_2_portrait: Texture2D


var dialogue: Array[Dictionary] = [
	{"text": "we are the proud guards of the Fall Zone Gate !", "speaker": "guard_1"},
	{"text": "during this period, it's safer for you to stay inside.", "speaker": "guard_2"},
	{"text": "the Outside World is not safe.", "speaker": "guard_2"},
	{"text": "sorry, little girl, you're gonna have to stay inside.", "speaker": "guard_1"},
]


func _ready():
	interaction_prompt.visible = false

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body):
	if body is Player:
		player_nearby = true
		interaction_prompt.visible = true


func _on_body_exited(body):
	if body is Player:
		player_nearby = false
		interaction_prompt.visible = false


func _process(_delta):
	if player_nearby \
	and Input.is_action_just_pressed("interact") \
	and not dialogue_box.dialogue_active:
		start_dialogue()


func start_dialogue():
	interaction_prompt.visible = false

	var prepared_dialogue := prepare_dialogue(dialogue)

	dialogue_box.start_dialogue(prepared_dialogue)


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
