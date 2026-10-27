extends Area2D

@export var npc_id: String = "knight"

var player_nearby := false
var current_dialogue_id: String = ""

@onready var interaction_prompt = $InteractionPrompt
@onready var new_dialogue_bubble = $DialogueBubble
@onready var dialogue_box: DialogueBox = $"../CanvasLayer/BoiteDialogues"


var first_dialogue: Array[String] = [
	"have we already met before?",
	"you know, it's dangerous for you out there...",
	"are you from the Outside World ?",
	"...",
	"you're the quiet type, aren't you ?",
	"I see...",
	"well, I guess I should introduce myself first then...",
	"I'm ???, I'm a former royal guard",
	"so what possibly can you be doing here ?",
	"looking for the princess ?",
	"to be honest, I have no idea where she might be",
	"but I know someone who does...",
	"you know, if you could do something from me, maybe I could help you",
	"you know how to fight ?",
	"I can see you have a sword with you",
	"why don't you go hunting for these monsters out there ?",
	"each one of them own a Precious Leaf",
	"I believe there is three of them here in the Fall Zone",
	"if you bring them to me, I will be willing to tell you everything I know"
]
var normal_dialogue: Array[String] = [
	"I'm busy right now...",
	"why don't you bring me those Precious Leaves ?"
]

var after_fall_quest: Array[String] = [
	"you really managed to gather all of them",
	"you are truly impressive."
]

var after_quest_dialogue: Array[String] = [
	"see you soon."
]

func _on_quest_completed(quest_id: String):
	if quest_id == "fall_quest":
		update_dialogue_bubble()
		
func _ready():
	interaction_prompt.visible = false

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	GameState.quest_completed.connect(_on_quest_completed)

	update_dialogue_bubble()

func _on_dialogue_finished():

	if current_dialogue_id == npc_id + "_first_meeting":
		GameState.start_quest("fall_quest")

	elif current_dialogue_id == npc_id + "_fall_quest":
		GameState.end_quest("fall_quest")

	current_dialogue_id = ""

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
	if GameState.is_quest_completed("fall_quest"):

		if not GameState.has_seen_dialogue(npc_id + "_fall_quest"):
			return npc_id + "_fall_quest"

		return npc_id + "_after_quest"

	if not GameState.has_seen_dialogue(npc_id + "_first_meeting"):
		return npc_id + "_first_meeting"

	return npc_id + "_normal"


func get_current_dialogue() -> Array[String]:
	var dialogue_id := get_current_dialogue_id()

	if dialogue_id == npc_id + "_first_meeting":
		return first_dialogue

	elif dialogue_id == npc_id + "_fall_quest":
		return after_fall_quest

	elif dialogue_id == npc_id + "_after_quest":
		return after_quest_dialogue

	else:
		return normal_dialogue


func update_dialogue_bubble():
	var dialogue_id := get_current_dialogue_id()
	if dialogue_id == npc_id + "_first_meeting":
		new_dialogue_bubble.visible = true

	elif dialogue_id == npc_id + "_fall_quest":
		new_dialogue_bubble.visible = true

	else:
		new_dialogue_bubble.visible = false
