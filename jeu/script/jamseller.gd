extends Area2D

var player_nearby := false

@onready var interaction_prompt = $InteractionPrompt
@onready var dialogue_box: DialogueBox = $"../CanvasLayer/BoiteDialogues"

@export var jamseller_portrait: Texture2D



var first_dialogue: Array[Dictionary] = [
	{"text": "whooooooo wants to give a try to our delicioooous cherry jam !", "speaker": "jamseller"},
	{"text": "YOU !", "speaker": "jamseller"},
	{"text": "are you new in Havenwood ?", "speaker": "jamseller"},
	{"text": "...", "speaker": "jamseller"},
	{"text": "I will take it for a yes.", "speaker": "jamseller"},
	{"text": "so..does that mean you never tried cherry jam ???", "speaker": "jamseller"},
	{"text": "ooh dear..you MUST try it.", "speaker": "jamseller"},
	{"text": "look..it's just between us, but I'm gonna give you a free sample.", "speaker": "jamseller"},
	{"text": "You obtained Cherry Jam (+20% Health Points)"}
	
]

var second_dialogue: Array[Dictionary] = [
	{"text": "can't wait for you to try my Cherry Jam !", "speaker": "jamseller"},
	{"text": "trust me, it's absolutely incredible !", "speaker": "jamseller"}
	
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


func start_dialogue() -> void:
	interaction_prompt.hide()

	var selected_dialogue: Array[Dictionary]

	if not GameState.jamseller_dialogue_seen:
		selected_dialogue = first_dialogue
		GameState.jamseller_dialogue_seen = true
		GameState.add_item("cherry_jam", 1)

	else:
		selected_dialogue = second_dialogue

	var prepared_dialogue := prepare_dialogue(selected_dialogue)
	dialogue_box.start_dialogue(prepared_dialogue)


func prepare_dialogue(source_dialogue: Array[Dictionary]) -> Array[Dictionary]:
	var prepared: Array[Dictionary] = []

	for message in source_dialogue:
		var new_message := message.duplicate()
		var speaker: String = message.get("speaker", "")

		if speaker == "jamseller":
			new_message["portrait"] = jamseller_portrait



		else:
			new_message["portrait"] = null

		prepared.append(new_message)

	return prepared
