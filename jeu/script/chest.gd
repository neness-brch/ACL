extends Area2D

var player_nearby := false

@onready var interaction_prompt = $InteractionPrompt
@onready var dialogue_box: DialogueBox = $"../CanvasLayer/BoiteDialogues"




var dialogue: Array[String] = [
	"nothing to see here...",
]

func _ready():
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
	if player_nearby and Input.is_action_just_pressed("interact"):
		dialogue_box.start_dialogue(dialogue)
