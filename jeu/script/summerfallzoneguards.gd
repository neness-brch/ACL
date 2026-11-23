
extends Area2D

var player_nearby := false
var current_dialogue_id: String = ""

const FALL_ZONE := "res://maingame.tscn"
const SUMMER_ZONE := "res://zone_2.tscn"

@onready var interaction_prompt = $InteractionPrompt
@onready var dialogue_box: DialogueBox = $"../CanvasLayer/BoiteDialogues"

@export var guard_1_portrait: Texture2D
@export var guard_2_portrait: Texture2D


var dialogue: Array[Dictionary] = [
	{"text": "we are the proud guards of the Summer/Fall Zone Gate !", "speaker": "guard_1"},
	{"text": "do you have a special pass ?", "speaker": "guard_2"},
	{"text": "...doesn't seem so", "speaker": "guard_2"},
	{"text": "therefore, you are not allowed to pass the gate", "speaker": "guard_2"},
	{"text": "sorry, these are the rules !", "speaker": "guard_1"},
]


var night_pass_dialogue: Array[Dictionary] = [
	{"text": "zzzzzzzzzzzz...", "speaker": "guard_1"},
	{"text": "what a day...", "speaker": "guard_2"},
	{"text": "sorry, the gate is closed until next morning !", "speaker": "guard_2"},
	{"text": "come back later !", "speaker": "guard_1"},
	{"text": "I mean... only if you have a Special Pass, of course.", "speaker": "guard_2"},
]


var morning_dialogue: Array[Dictionary] = [
	{"text": "we are the proud guards of the Summer/Fall Zone Gate !", "speaker": "guard_1"},
	{"text": "do you have a special pass ?", "speaker": "guard_2"},
	{"text": "...looks like it !", "speaker": "guard_2"},
	{"text": "have a great time there !", "speaker": "guard_1"},
]


func _ready():
	interaction_prompt.visible = false

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)


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
	var selected_dialogue: Array[Dictionary]

	# CASE 1 : pas de Special Pass
	if not GameState.knight_house_dialogue_seen:
		current_dialogue_id = "normal"
		selected_dialogue = dialogue

	# CASE 2 : passage déjà débloqué
	elif GameState.summer_gate_open:
		current_dialogue_id = "short"
		selected_dialogue = get_short_dialogue()

	# CASE 3 : premier passage, après avoir dormi et au matin
	elif GameState.has_slept_after_knight_dialogue \
	and GameState.time_progress == 0:
		current_dialogue_id = "morning"
		selected_dialogue = morning_dialogue

	# CASE 4 : Special Pass obtenu, mais premier passage pas encore autorisé
	else:
		current_dialogue_id = "night_pass"
		selected_dialogue = night_pass_dialogue

	interaction_prompt.visible = false

	var prepared_dialogue := prepare_dialogue(selected_dialogue)
	dialogue_box.start_dialogue(prepared_dialogue)


func get_short_dialogue() -> Array[Dictionary]:
	var destination := get_destination_scene()
	var destination_name := "summer" if destination == SUMMER_ZONE else "fall"

	return [
		{"text": "we are the proud guards of the Summer/Fall Zone Gate !", "speaker": "guard_1"},
		{"text": "have a good time in the " + destination_name + " zone !", "speaker": "guard_2"},
	]


func get_destination_scene() -> String:
	var current_scene := get_tree().current_scene.scene_file_path

	if current_scene == SUMMER_ZONE:
		return FALL_ZONE

	return SUMMER_ZONE


func _on_dialogue_finished():
	var should_transition := false

	if current_dialogue_id == "morning":
		GameState.summer_gate_open = true
		should_transition = true

	elif current_dialogue_id == "short":
		should_transition = true

	current_dialogue_id = ""

	if should_transition:
		SceneTransition.change_scene(get_destination_scene())
	elif player_nearby:
		interaction_prompt.visible = true


func prepare_dialogue(source_dialogue: Array[Dictionary]) -> Array[Dictionary]:
	var prepared: Array[Dictionary] = []

	for message in source_dialogue:
		var new_message := message.duplicate()
		var speaker: String = message.get("speaker", "")

		if speaker == "guard_1":
			new_message["portrait"] = guard_1_portrait

		elif speaker == "guard_2":
			new_message["portrait"] = guard_2_portrait

		else:
			new_message["portrait"] = null

		prepared.append(new_message)

	return prepared
