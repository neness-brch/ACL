extends Area2D

var player_nearby := false

@onready var interaction_prompt = $InteractionPrompt
@onready var dialogue_box: DialogueBox = $"../CanvasLayer/BoiteDialogues"

@export var pnj_3_portrait: Texture2D



var dialogue: Array[Dictionary] = [
	{"text": "look what we have here !", "speaker": "pnj3"},
	{"text": "a girl with a sword ", "speaker": "pnj3"},
	{"text": "you sure look like a stranger like this.", "speaker": "pnj3"},
	{"text": "nobody does that here.", "speaker": "pnj3"},
	{"text": "well, apart from the Princess...", "speaker": "pnj3"},
	{"text": "she used to carry a sword every time she'd go outside a few months ago", "speaker": "pnj3"},
	{"text": "like an old habit from her early life..", "speaker": "pnj3"},
	{"text": "...she finally understood it was pointless.", "speaker": "pnj3"},
	{"text": "she's the one who needs to be protected, not the one who needs to fight !", "speaker": "pnj3"},
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

		if speaker == "pnj3":
			new_message["portrait"] = pnj_3_portrait



		else:
			new_message["portrait"] = null

		prepared.append(new_message)

	return prepared
