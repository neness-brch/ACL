extends Area2D

var player_nearby := false

@onready var interaction_prompt = $InteractionPrompt
@onready var dialogue_box: DialogueBox = $"../CanvasLayer/BoiteDialogues"

@export var pnj_1_portrait: Texture2D



var dialogue: Array[Dictionary] = [
	{"text": "good to see some new faces here !", "speaker": "pnj1"},
	{"text": "did you come for the festival ??", "speaker": "pnj1"},
	{"text": "can't wait to see the Earl !", "speaker": "pnj1"}
	
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

		if speaker == "pnj1":
			new_message["portrait"] = pnj_1_portrait



		else:
			new_message["portrait"] = null

		prepared.append(new_message)

	return prepared
