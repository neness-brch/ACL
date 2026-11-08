
extends Area2D

@export var portrait: Texture2D

var player_nearby := false
var current_dialogue_id: String = ""

@onready var interaction_prompt = $InteractionPrompt
@onready var new_dialogue_bubble = $BulleDialogue
@onready var dialogue_box: DialogueBox = $"../CanvasLayer/BoiteDialogues"


# Dialogue principal : première rencontre dans la maison
var house_dialogue: Array[String] = [
	"so...",
	"here we are.",
	"what do you want to know?",
	"...",
	"come on... you think I'm gonna guess by myself?",
	"...",
	"alright...",
	"it's about the Princess, isn't it?",
	"well, she's been here for four years now...",
	"she lives in Havenwood Palace, in the Spring Zone.",
	"I don't know much more, unfortunately...",
	"look... I have no idea what makes you want to meet the Princess...",
	"but you have to know she's not easy to reach.",
	"only a few people are allowed inside Havenwood Palace.",
	"even I, a former Royal Guard, don't have authorization to enter.",
	"the only way you could see her would be at Havenwood's Yearly Festival.",
	"it's a unique occasion where the Earl gives a speech to the entire village.",
	"she might be there, or she might not...",
	"and even if you did see her, getting close to her would be difficult.",
	"there are Special Guards everywhere.",
	"you'd have to get her attention somehow.",
	"the Earl seems to really care about her.",
	"that's probably why they got married last year.",
	"...",
	"that's funny. Your expression changed quite a bit when I said that.",
	"never mind...",
	"I suggest you head to the Summer Zone tomorrow.",
	"find ???.",
	"he's in charge of the Royal Guards.",
	"of all the people I know, he might be the only one who knows more about the Princess.",
	"tell him you came from me. he'll be glad to hear from me!",
	"it's been a long time since I've seen him...",
	"anyway, you'll probably need this.",
	"You obtained a Special Pass for the Summer Zone!",
	"you need some rest now.",
	"you've had a long day.",
	"pick any bed you want!",
	"oh, and feel free to explore the Fall Zone before going to sleep. there's plenty of interesting stuff to discover!",
	"the church bell will wake you up in the morning.",
	"good night, and good luck!"
]


# Dialogue secondaire : toutes les interactions suivantes
var repeat_dialogue: Array[String] = [
	"oh, you're still here?",
	"make yourself at home!",
	"I'll be around if you need anything."
]


func _ready() -> void:
	interaction_prompt.visible = false

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)

	update_dialogue_bubble()


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_nearby = true
		interaction_prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_nearby = false
		interaction_prompt.visible = false


func _process(_delta: float) -> void:
	if player_nearby \
	and Input.is_action_just_pressed("interact") \
	and not dialogue_box.dialogue_active:

		start_dialogue()


func start_dialogue() -> void:

	if not GameState.knight_house_dialogue_seen:
		current_dialogue_id = "knight_house_first"
		dialogue_box.start_dialogue(house_dialogue, portrait)

	else:
		current_dialogue_id = "knight_house_repeat"
		dialogue_box.start_dialogue(repeat_dialogue, portrait)

	interaction_prompt.hide()
	new_dialogue_bubble.hide()


func _on_dialogue_finished() -> void:

	if current_dialogue_id == "knight_house_first":
		GameState.knight_house_dialogue_seen = true

	current_dialogue_id = ""

	update_dialogue_bubble()


func update_dialogue_bubble() -> void:
	new_dialogue_bubble.visible = not GameState.knight_house_dialogue_seen
