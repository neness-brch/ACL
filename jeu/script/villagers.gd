extends Area2D

@export var npc_id: String = "villagers"

var player_nearby := false
var current_dialogue_id: String = ""

@onready var interaction_prompt = $InteractionPrompt
@onready var new_dialogue_bubble = $DialogueBubble
@onready var dialogue_box: DialogueBox = $"../CanvasLayer/BoiteDialogues"


var before_quest_dialogue: Array[String] = [
	"???, we've talked about this many times",
	"this place is not safe for you anymore.",
	"you know very well these monsters are freaking me out",
	"but...",
	"there's no...",
	"wait...",
	"who are you ?",
	"...",
	"HELLOOOOOO ?",
	"looks like she doesn't want to talk",
	"what do you want then ?",
	"...",
	"a sword...are you a knight or something ?",
	"you don't look like you're from here",
	"aaargh...",
	"this is annoying.",
	"look...",
	"do you think you could...",
	"get rid of these monsters for us ?",
	"go talk to that knight up there, he might have some extra information about them",
	"be careful."
	]

var first_meeting_during_quest_dialogue: Array[String] = [
	"???, we've talked about this many times",
	"this place is not safe for you anymore.",
	"you know very well these monsters are freaking me out",
	"but...",
	"there's no...",
	"wait...",
	"who are you ?",
	"...",
	"HELLOOOOOO ?",
	"looks like she doesn't want to talk",
	"what do you want then ?",
	"...",
	"a sword...are you a knight or something ?",
	"you don't look like you're from here",
	"are you on your way to kill the monsters ?",
	"thank god...",
	"my stubborn daughter won't listen to me...",
	"she wants to fight them but has no clue how to do it",
	"but you...",
	"you look like you have a lot a experience.",
	"please save us.",
	"and be careful, these monsters are smarter than you think."
	
]

var quest_started_after_meeting_dialogue: Array[String] = [
	"so you came to the knight, is it ?",
	"well, good luck."
]

var normal_dialogue: Array[String] = [
	"good luck out there."
]

var potion_dialogue: Array[String] = [
	"You obtained a Health Potion."
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

	interaction_prompt.visible = false

	GameState.mark_dialogue_seen(current_dialogue_id)
	update_dialogue_bubble()

	dialogue_box.start_dialogue(dialogue)


func get_current_dialogue_id() -> String:

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


func get_current_dialogue() -> Array[String]:
	var dialogue_id := get_current_dialogue_id()

	if dialogue_id == npc_id + "_before_quest":
		return before_quest_dialogue

	elif dialogue_id == npc_id + "_during_quest":
		return first_meeting_during_quest_dialogue

	elif dialogue_id == npc_id + "_quest_update":
		return quest_started_after_meeting_dialogue

	else:
		return normal_dialogue


func _on_dialogue_finished():
	# Potion after Hello2 or Hello3
	if current_dialogue_id == npc_id + "_during_quest" \
	or current_dialogue_id == npc_id + "_quest_update":

		if not GameState.has_seen_dialogue(npc_id + "_potion_received"):
			GameState.mark_dialogue_seen(npc_id + "_potion_received")
			current_dialogue_id = npc_id + "_potion_message"
			dialogue_box.start_dialogue(potion_dialogue)
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
	)
