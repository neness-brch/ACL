extends Control
class_name DialogueBox

@export var chars_per_second := 40.0
@export var monster_chars_per_second := 300.0

@export var normal_pitch_min := 0.95
@export var normal_pitch_max := 1.05

@export var monster_pitch_min := 0.55
@export var monster_pitch_max := 0.70

var current_speaker: String = ""

@onready var label: RichTextLabel = $VBoxContainer/Dialog
@onready var voice_player: AudioStreamPlayer = $VoicePlayer
@onready var voice_timer: Timer = $VoiceTimer
@onready var portrait_panel: Panel = $Portrait
@onready var portrait: TextureRect = $Portrait/Portrait

var messages: Array = []
var current_message := 0
var dialogue_active := false
var tween: Tween

signal dialogue_finished


func _ready():
	visible = false
	voice_timer.timeout.connect(_on_voice_timer_timeout)


func start_dialogue(new_messages: Array, default_portrait: Texture2D = null):
	messages = []

	for message in new_messages:
		if message is String:
			messages.append({
				"text": message,
				"portrait": default_portrait
			})
		else:
			messages.append(message)

	current_message = 0
	dialogue_active = true
	visible = true

	show_message()


func show_message():
	var message = messages[current_message]

	label.text = message["text"]
	current_speaker = message.get("speaker", "")

	var speaker_portrait: Texture2D = message.get("portrait", null)

	if speaker_portrait != null:
		portrait.texture = speaker_portrait
		portrait_panel.visible = true
	else:
		portrait_panel.visible = false

	label.visible_ratio = 0.0

	if tween:
		tween.kill()

	voice_timer.start()

	var speed := chars_per_second

	if current_speaker == "monster":
		speed = monster_chars_per_second

	var duration := label.get_total_character_count() / speed

	tween = create_tween()
	tween.tween_property(label, "visible_ratio", 1.0, duration)
	tween.tween_callback(voice_timer.stop)


func _on_voice_timer_timeout():
	if tween and tween.is_running():

		if current_speaker == "monster":
			voice_player.pitch_scale = randf_range(
				monster_pitch_min,
				monster_pitch_max
			)
		else:
			voice_player.pitch_scale = randf_range(
				normal_pitch_min,
				normal_pitch_max
			)

		voice_player.play()


func _process(_delta):
	if dialogue_active and Input.is_action_just_pressed("next_dialogue"):
		if tween and tween.is_running():
			tween.kill()
			voice_timer.stop()
			voice_player.stop()
			label.visible_ratio = 1.0
		else:
			next_message()


func next_message():
	current_message += 1

	if current_message < messages.size():
		show_message()
	else:
		close_dialogue()


func close_dialogue():
	if tween:
		tween.kill()

	voice_timer.stop()
	voice_player.stop()

	dialogue_active = false
	label.text = ""
	messages.clear()
	visible = false
	dialogue_finished.emit()
