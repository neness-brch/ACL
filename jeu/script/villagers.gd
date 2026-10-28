extends Area2D

@export var npc_id: String = "villagers"

var player_nearby := false
var current_dialogue_id: String = ""

@onready var interaction_prompt = $InteractionPrompt
@onready var new_dialogue_bubble = $DialogueBubble
@onready var dialogue_box: DialogueBox = $"../CanvasLayer/BoiteDialogues"
@export var dad_portrait: Texture2D
@export var daughter_portrait: Texture2D


var before_quest_dialogue: Array[Dictionary] = [
	{"text": "...I knew I shouldn't have let him go play without supervision.", "speaker": "dad"},
	{"text": "It's been a few hours and they still haven't come back.", "speaker": "dad"},
	{"text": "I'm sure those monsters killed him...", "speaker": "dad"},

	{"text": "dad, let me go look for him.", "speaker": "daughter"},
	{"text": "I swear I'll kill those monsters if they're responsible!", "speaker": "daughter"},

	{"text": "you're not going anywhere. It's too dangerous, and I don't want to lose both my children on the same day.", "speaker": "dad"},

	{"text": "so you're just going to wait for him to come back? and do nothing?!", "speaker": "daughter"},

	{"text": "even the Royal Guards are struggling against them, and you think you can do something? how naive...", "speaker": "dad"},
	{"text": "wait... who are you? have you been listening this whole time?", "speaker": "dad"},
	{"text": "...", "speaker": "dad"},
	{"text": "HELLOOOOOO?", "speaker": "dad"},

	{"text": "looks like she doesn't want to talk.", "speaker": "daughter"},

	{"text": "what do you want, then?", "speaker": "dad"},
	{"text": "...", "speaker": "dad"},
	{"text": "a sword... are you a knight or something?", "speaker": "dad"},
	{"text": "that can't be. you don't look like you're from around here.", "speaker": "dad"},
	{"text": "do you think... you could help us find our son?", "speaker": "dad"},
	{"text": "because...", "speaker": "dad"},
	{"text": "my stubborn daughter won't listen to me...", "speaker": "dad"},
	{"text": "she wants to fight them, but she has no idea what she's getting herself into.", "speaker": "dad"},
	{"text": "I can't lose her too. It's too risky.", "speaker": "dad"},
	{"text": "but you...", "speaker": "dad"},
	{"text": "you look like you have a lot of experience.", "speaker": "dad"},
	{"text": "if you bring my son back, I would be so grateful.", "speaker": "dad"},
	{"text": "the last time I saw him, he was heading south with his friends.", "speaker": "dad"},
	{"text": "but before you do anything, please go talk to that knight up there.", "speaker": "dad"},
	{"text": "he might have some valuable information about those monsters.", "speaker": "dad"},
	{"text": "and please... be careful.", "speaker": "dad"},
	{"text": "those monsters are smarter than you think.", "speaker": "dad"},
	

	{"text": "please bring my little brother back.", "speaker": "daughter"},
	{"text": "you're our only hope.", "speaker": "daughter"},
	{"text": "here is something to help you.", "speaker": "dad"}
]


var first_meeting_during_quest_dialogue: Array[Dictionary] = [
	{"text": "...I knew I shouldn't have let him go play without supervision.", "speaker": "dad"},
	{"text": "it's been a few hours and they still haven't come back.", "speaker": "dad"},
	{"text": "I'm sure those monsters killed him...", "speaker": "dad"},

	{"text": "dad, let me go look for him.", "speaker": "daughter"},
	{"text": "I swear I'll kill those monsters if they're responsible!", "speaker": "daughter"},

	{"text": "you're not going anywhere. It's too dangerous, and I don't want to lose both my children on the same day.", "speaker": "dad"},

	{"text": "so you're just going to wait for him to come back? and do nothing?!", "speaker": "daughter"},

	{"text": "even the Royal Guards are struggling against them, and you think you can do something? How naive...", "speaker": "dad"},
	{"text": "wait... who are you? have you been listening this whole time?", "speaker": "dad"},
	{"text": "...", "speaker": "dad"},
	{"text": "HELLOOOOOO?", "speaker": "dad"},

	{"text": "looks like she doesn't want to talk.", "speaker": "daughter"},

	{"text": "what do you want, then?", "speaker": "dad"},
	{"text": "...", "speaker": "dad"},
	{"text": "a sword... are you a knight or something?", "speaker": "dad"},
	{"text": "that can't be. you don't look like you're from around here.", "speaker": "dad"},
	{"text": "are you on your way to fight those monsters?", "speaker": "dad"},
	{"text": "thank God...", "speaker": "dad"},
	{"text": "my stubborn daughter won't listen to me...", "speaker": "dad"},
	{"text": "she wants to fight them, but she has no idea what she's getting herself into.", "speaker": "dad"},
	{"text": "but you...", "speaker": "dad"},
	{"text": "you look like you have a lot of experience.", "speaker": "dad"},
	{"text": "if you bring my son back, I would be so grateful.", "speaker": "dad"},
	{"text": "the last time I saw him, he was heading south with his friends.", "speaker": "dad"},
	{"text": "please... be careful.", "speaker": "dad"},
	{"text": "those monsters are smarter than you think.", "speaker": "dad"},
	

	{"text": "please bring my little brother back.", "speaker": "daughter"},
	{"text": "you're our only hope.", "speaker": "daughter"},
	{"text": "here is something to help you.", "speaker": "dad"}
]


var quest_started_after_meeting_dialogue: Array[Dictionary] = [
	{"text": "so, you went to see the knight?", "speaker": "dad"},
	{"text": "...well, good luck out there.", "speaker": "dad"},
	{"text": "and please... find Tim.", "speaker": "dad"}
]


var normal_dialogue: Array[Dictionary] = [
	{"text": "did you find Tim?", "speaker": "daughter"},
	{"text": "he was heading south the last time we saw him.", "speaker": "daughter"}
]


var potion_dialogue: Array[Dictionary] = [
	{"text": "You obtained a Health Potion."}
]

var ability_dialogue: Array[Dictionary] = [
	{"text": "You learned a Special Attack."}
]

var tim_return_dialogue: Array[Dictionary] = [
	{"text": "TIM !", "speaker": "dad"},
	{"text": "where were you ?", "speaker": "dad"},
	{"text": "thank you for bringing him back", "speaker": "daughter"},
	{"text": "...", "speaker": "dad"},
	{"text": "so you did beat this monster, right ?", "speaker": "daughter"},
	{"text": "I knew we could trust you !", "speaker": "daughter"},
	{"text": "I guess, I owe you something now...", "speaker": "dad"},
]

func _ready():
	interaction_prompt.visible = false

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	GameState.quest_active_changed.connect(_on_quest_active_changed)

	update_dialogue_bubble()


func _on_body_entered(body):
	if body is Player:
		player_nearby = true
		interaction_prompt.visible = true
		update_dialogue_bubble()
		
	print("tim_needs_escort = ", GameState.tim_needs_escort)
	print("dialogue = ", get_current_dialogue_id())
	print("seen = ", GameState.has_seen_dialogue(npc_id + "_tim_found"))


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
	current_dialogue_id = get_current_dialogue_id()

	var dialogue := get_current_dialogue()
	var prepared_dialogue := prepare_dialogue(dialogue)

	interaction_prompt.visible = false

	GameState.mark_dialogue_seen(current_dialogue_id)
	update_dialogue_bubble()

	dialogue_box.start_dialogue(prepared_dialogue)


func get_current_dialogue_id() -> String:
	
	if GameState.tim_needs_escort:
		if not GameState.has_seen_dialogue(npc_id + "_tim_found"):
			return npc_id + "_tim_found"

	# Fall Quest hasn't started yet
	if not GameState.is_quest_active("fall_quest"):
		if not GameState.has_seen_dialogue(npc_id + "_before_quest"):
			return npc_id + "_before_quest"

		return npc_id + "_normal"


	# Fall Quest is active, but we've NEVER met this villager
	if not GameState.has_seen_dialogue(npc_id + "_before_quest") \
	and not GameState.has_seen_dialogue(npc_id + "_during_quest"):
		return npc_id + "_during_quest"


	# We met the villager BEFORE starting the Fall Quest
	if GameState.has_seen_dialogue(npc_id + "_before_quest") \
	and not GameState.has_seen_dialogue(npc_id + "_quest_update"):
		return npc_id + "_quest_update"


	return npc_id + "_normal"


func get_current_dialogue() -> Array[Dictionary]:
	var dialogue_id := get_current_dialogue_id()
	
	if dialogue_id == npc_id + "_tim_found":
		return tim_return_dialogue

	if dialogue_id == npc_id + "_before_quest":
		return before_quest_dialogue

	elif dialogue_id == npc_id + "_during_quest":
		return first_meeting_during_quest_dialogue

	elif dialogue_id == npc_id + "_quest_update":
		return quest_started_after_meeting_dialogue

	else:
		return normal_dialogue


func _on_dialogue_finished():
	if current_dialogue_id == npc_id + "_during_quest" \
	or current_dialogue_id == npc_id + "_quest_update":

		if not GameState.has_seen_dialogue(npc_id + "_potion_received"):
			GameState.mark_dialogue_seen(npc_id + "_potion_received")
			GameState.add_item("health_potion", 1)
			current_dialogue_id = npc_id + "_potion_message"
			dialogue_box.start_dialogue(potion_dialogue)
			return
	
	if current_dialogue_id == npc_id + "_tim_found":
		current_dialogue_id = npc_id + "_ability"

		var prepared_dialogue := prepare_dialogue(ability_dialogue)
		dialogue_box.start_dialogue(prepared_dialogue)
		return

	current_dialogue_id = ""
	update_dialogue_bubble()


func _on_quest_active_changed(quest_id: String, active: bool):
	if quest_id == "fall_quest" and active:
		update_dialogue_bubble()


func update_dialogue_bubble():
	var dialogue_id := get_current_dialogue_id()

	new_dialogue_bubble.visible = (
		dialogue_id == npc_id + "_before_quest"
		or dialogue_id == npc_id + "_during_quest"
		or dialogue_id == npc_id + "_quest_update"
		or dialogue_id == npc_id + "_tim_found"
	)
	
func prepare_dialogue(dialogue: Array[Dictionary]) -> Array[Dictionary]:
	var prepared: Array[Dictionary] = []

	for message in dialogue:
		var new_message := message.duplicate()
		var speaker: String = message.get("speaker", "")

		if speaker == "dad":
			new_message["portrait"] = dad_portrait

		elif speaker == "daughter":
			new_message["portrait"] = daughter_portrait

		else:
			new_message["portrait"] = null

		prepared.append(new_message)

	return prepared
