
extends Area2D

var player_nearby := false
var current_dialogue_id: String = ""

var was_night := false
var music_was_paused := false
var music_paused_by_npc := false

@export var pnj_4_portrait: Texture2D
@export var night_position: Vector2 = Vector2.ZERO

@onready var collision: CollisionShape2D = $"../FallZoneCollision/PNJ4Collision"
@onready var interaction_prompt = $InteractionPrompt
@onready var dialogue_box: DialogueBox = $"../CanvasLayer/BoiteDialogues"
@onready var music_player: AudioStreamPlayer = $"../MusicNode/AudioStreamPlayer"


var first_dialogue: Array[Dictionary] = [
	{"text": "can't talk right now.", "speaker": "pnj4"},
	{"text": "I'll meet you at the lake tonight if you want information about the Princess.", "speaker": "pnj4"},
	{"text": "this is your only chance.", "speaker": "pnj4"},
	{"text": "I'll be gone by tomorrow morning.", "speaker": "pnj4"}
]

var night_dialogue: Array[Dictionary] = [
	{"text": "I knew you would come.", "speaker": "pnj4"},
	{"text": "we don't have much time so I will be very straightforward.", "speaker": "pnj4"},
	{"text": "I saw you talking to a Royal Guard.", "speaker": "pnj4"},
	{"text": "don't trust him.", "speaker": "pnj4"},
	{"text": "nor the other guards.", "speaker": "pnj4"},
	{"text": "all they do is protect the Earl and keep people away from the Princess.", "speaker": "pnj4"},
	{"text": "I have a plan for you.", "speaker": "pnj4"},
	{"text": "go talk to Mayrina in the Summer Zone.", "speaker": "pnj4"},
	{"text": "she personally knows the Princess and knows a way to reach her.", "speaker": "pnj4"},
	{"text": "I wish I could stay with you and fight by your side.", "speaker": "pnj4"},
	{"text": "unfortunately, I have important things to do.", "speaker": "pnj4"},
	{"text": "I'll do everything in my power to help you find the Princess.", "speaker": "pnj4"},
	{"text": "I do believe you might have important things to tell her.", "speaker": "pnj4"},
	{"text": "I'm not abandoning you, though.", "speaker": "pnj4"},
	{"text": "I'll be there when you need me most. Think of it as emergency assistance.", "speaker": "pnj4"},
	{"text": "you should rest and head to the Summer Zone tomorrow.", "speaker": "pnj4"},
	{"text": "I wish you the best.", "speaker": "pnj4"}
]

var night_repeat_dialogue: Array[Dictionary] = [
	{"text": "I've told you everything I can.", "speaker": "pnj4"},
	{"text": "please go to sleep and head to the Summer Zone in the morning.", "speaker": "pnj4"},
	{"text": "Mayrina might be your only chance.", "speaker": "pnj4"}
]

var day_repeat_dialogue: Array[Dictionary] = [
	{"text": "can't talk right now.", "speaker": "pnj4"}
]


func _ready() -> void:
	interaction_prompt.visible = false

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	GameState.time_of_day_changed.connect(_on_time_of_day_changed)

	update_npc_position(GameState.time_progress)


func _on_body_entered(body) -> void:
	if body is Player and visible:
		player_nearby = true
		interaction_prompt.visible = true


func _on_body_exited(body) -> void:
	if body is Player:
		player_nearby = false
		interaction_prompt.visible = false


func _process(_delta) -> void:
	if player_nearby \
	and Input.is_action_just_pressed("interact") \
	and not dialogue_box.dialogue_active:
		start_dialogue()


func start_dialogue() -> void:
	if not visible or GameState.pnj4_disappeared:
		return

	interaction_prompt.visible = false

	var selected_dialogue: Array[Dictionary]
	var is_night := GameState.time_progress >= 3.0

	if is_night:
		if not GameState.pnj4_intro_seen:
			return

		if not GameState.pnj4_night_dialogue_seen:
			current_dialogue_id = "night"
			selected_dialogue = night_dialogue
			GameState.pnj4_night_dialogue_seen = true
		else:
			current_dialogue_id = "night_repeat"
			selected_dialogue = night_repeat_dialogue

	else:
		if not GameState.pnj4_intro_seen:
			current_dialogue_id = "intro"
			selected_dialogue = first_dialogue
			GameState.pnj4_intro_seen = true
		else:
			current_dialogue_id = "day_repeat"
			selected_dialogue = day_repeat_dialogue

	if current_dialogue_id == "intro" or current_dialogue_id == "night":
		pause_music()

	var prepared_dialogue := prepare_dialogue(selected_dialogue)
	dialogue_box.start_dialogue(prepared_dialogue)


func prepare_dialogue(source_dialogue: Array[Dictionary]) -> Array[Dictionary]:
	var prepared: Array[Dictionary] = []

	for message in source_dialogue:
		var new_message := message.duplicate()
		var speaker: String = message.get("speaker", "")

		if speaker == "pnj4":
			new_message["portrait"] = pnj_4_portrait
		else:
			new_message["portrait"] = null

		prepared.append(new_message)

	return prepared


func pause_music() -> void:
	if music_player == null:
		return

	music_was_paused = music_player.stream_paused
	music_player.stream_paused = true
	music_paused_by_npc = true


func resume_music() -> void:
	if music_player == null or not music_paused_by_npc:
		return

	music_player.stream_paused = music_was_paused
	music_paused_by_npc = false


func _on_dialogue_finished() -> void:
	resume_music()
	current_dialogue_id = ""


func _on_time_of_day_changed(progress: float) -> void:
	if was_night and progress < 3.0:
		GameState.pnj4_disappeared = true

	update_npc_position(progress)


func update_npc_position(progress: float) -> void:

	if GameState.pnj4_disappeared:
		visible = false
		monitoring = false
		player_nearby = false
		interaction_prompt.hide()
		collision.set_deferred("disabled", true)
		return

	if progress >= 3.0:

		if not GameState.pnj4_intro_seen:
			GameState.pnj4_disappeared = true

			visible = false
			monitoring = false
			player_nearby = false
			interaction_prompt.hide()
			collision.set_deferred("disabled", true)
			return

		var displacement: Vector2 = night_position - global_position

		global_position = night_position
		collision.global_position += displacement

		visible = true
		monitoring = true
		collision.set_deferred("disabled", false)

		was_night = true

	else:
		visible = true
		monitoring = true
		collision.set_deferred("disabled", false)
