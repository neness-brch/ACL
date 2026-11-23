extends Area2D

@export var npc_id: String = "summer_knight"

var player_nearby := false
var current_dialogue_id: String = ""

@onready var interaction_prompt = $InteractionPrompt
@onready var new_dialogue_bubble = $BulleDialogue
@onready var dialogue_box: DialogueBox = $CanvasLayer/BoiteDialogues
@export var portrait: Texture2D


var first_dialogue: Array[String] = [
	"... I see",
	"so you came all the way from the Fall Zone.",
	"look...it's pretty much dead here.",
	"the drought is affecting everyone.",
	"and we don't have a lot of water as well",
	"the monsters stole them from us.",
	"the whole army of the Summer Zone tried to beat them but they couldn't.",
	"you could give it a try, of course.",
	"ahah! just kidding. it would be pure suicide.",
	"however, you may be our last hope. the Earl isn't coming to save us anyway.",
	"we have to deal with this on our own.",
	"look, let me come with you and fight these monsters with you.",
	"I might have some experience fighting with them.",
	"the three of them holds a Precious Flame.",
	"once we get rid of them, I guess I will owe you something.",
	"but we'll talk about this later."
]
var normal_dialogue: Array[String] = [
	"I'll be here when you're ready to fight. let's go."
]

var after_summer_quest: Array[String] = [
	"so you finally got the three Precious Flames",
	"what do you want in exchange then ?"
]

var after_quest_dialogue: Array[String] = [
	"let's make a deal"
]

func _on_quest_completed(quest_id: String):
	if quest_id == "summer_quest":
		update_dialogue_bubble()
		
func _ready():

	interaction_prompt.visible = false

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	GameState.quest_completed.connect(_on_quest_completed)
	GameState.quest_active_changed.connect(_on_quest_active_changed)

	update_dialogue_bubble()

func _on_dialogue_finished():

		if current_dialogue_id == npc_id + "_first_meeting":
			GameState.start_quest("summer_quest")

		elif current_dialogue_id == npc_id + "_summer_quest":
			GameState.end_quest("summer_quest")
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
	if GameState.is_quest_completed("summer_quest"):

		if not GameState.has_seen_dialogue(npc_id + "_summer_quest"):
			return npc_id + "_summer_quest"

		return npc_id + "_after_quest"

	if not GameState.is_quest_active("summer_quest"):
		return npc_id + "_first_meeting"

	return npc_id + "_normal"


func get_current_dialogue() -> Array[String]:
	var dialogue_id := get_current_dialogue_id()

	if dialogue_id == npc_id + "_first_meeting":
		return first_dialogue

	elif dialogue_id == npc_id + "_summer_quest":
		return after_summer_quest

	elif dialogue_id == npc_id + "_after_quest":
		return after_quest_dialogue

	else:
		return normal_dialogue


func update_dialogue_bubble():
	var dialogue_id := get_current_dialogue_id()

	new_dialogue_bubble.visible = (
		dialogue_id == npc_id + "_first_meeting"
		or (
			dialogue_id == npc_id + "_summer_quest"
			and not GameState.has_seen_dialogue(dialogue_id)
		)
	)
	
func _on_quest_active_changed(quest_id: String, _active: bool):
	if quest_id == "summer_quest":
		update_dialogue_bubble()
