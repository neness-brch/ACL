extends Area2D

@export var npc_id: String = "knight"

var player_nearby := false
var current_dialogue_id: String = ""

@onready var interaction_prompt = $InteractionPrompt
@onready var new_dialogue_bubble = $BulleDialogue
@onready var dialogue_box: DialogueBox = $CanvasLayer/BoiteDialogues
@export var portrait: Texture2D


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
	"she is quite discreet lately to be honest",
	"you know, perhaps we could make a deal. you do something for me, and I'll tell you what I know.",
	"you know how to fight ?",
	"I can see you have a sword with you",
	"why don't you hunt down these monsters out there ?",
	"they are scaring the villagers.",
	"each one of them carries a Precious Leaf",
	"I believe there are three of them here in the Fall Zone",
	"if you bring them to me, I will be willing to tell you everything I know"
]
var normal_dialogue: Array[String] = [
	"I'm busy right now...",
	"why don't you bring me those Precious Leaves ?"
]

var after_fall_quest: Array[String] = [
	"you really managed to gather all of them",
	"you are truly impressive.",
	"so...as I promised to you...",
"I will tell you everything I know.",
"but before that, we should go to my place first.",
"the night is coming and you will need rest.",
"go find my house on the village up there, I'll meet you there"
]

var after_quest_dialogue: Array[String] = [
	"did you find my house?",
	"it's a big house,you can't miss it !"
]

func _on_quest_completed(quest_id: String):
	if quest_id == "fall_quest":
		update_dialogue_bubble()
		
func _ready():
	if GameState.knight_has_moved_to_house:
		hide()
		set_deferred("monitoring", false)
		set_deferred("monitorable", false)
		return

	interaction_prompt.visible = false

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	GameState.quest_completed.connect(_on_quest_completed)
	GameState.quest_active_changed.connect(_on_quest_active_changed)

	update_dialogue_bubble()

func _on_dialogue_finished():

		if current_dialogue_id == npc_id + "_first_meeting":
			GameState.start_quest("fall_quest")

		elif current_dialogue_id == npc_id + "_fall_quest":
			GameState.end_quest("fall_quest")
			GameState.knight_house_unlocked = true

		current_dialogue_id = ""
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

	interaction_prompt.hide()
	new_dialogue_bubble.hide()

	GameState.mark_dialogue_seen(current_dialogue_id)

	dialogue_box.start_dialogue(dialogue, portrait)


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

	new_dialogue_bubble.visible = (
		not GameState.has_seen_dialogue(dialogue_id)
		and (
			dialogue_id == npc_id + "_first_meeting"
			or dialogue_id == npc_id + "_fall_quest"
		)
	)
	
func _on_quest_active_changed(quest_id: String, _active: bool):
	if quest_id == "fall_quest":
		update_dialogue_bubble()
