extends Control
class_name DialogueBox

@export var chars_per_second := 40.0

@onready var label: RichTextLabel = $VBoxContainer/Dialog
@onready var voice_player: AudioStreamPlayer = $VoicePlayer
@onready var voice_timer: Timer = $VoiceTimer

var messages: Array[String] = []
var current_message := 0
var dialogue_active := false
var tween: Tween

signal dialogue_finished


func _ready():
	visible = false
	voice_timer.timeout.connect(_on_voice_timer_timeout)


func start_dialogue(new_messages: Array[String]):
	messages = new_messages.duplicate()
	current_message = 0
	dialogue_active = true
	visible = true
	show_message()


func show_message():
	label.text = messages[current_message]
	label.visible_ratio = 0.0

	if tween:
		tween.kill()

	voice_timer.start()

	var duration := label.get_total_character_count() / chars_per_second
	tween = create_tween()
	tween.tween_property(label, "visible_ratio", 1.0, duration)

	# Stop the voice when the text finishes appearing
	tween.tween_callback(voice_timer.stop)


func _on_voice_timer_timeout():
	if tween and tween.is_running():
		voice_player.pitch_scale = randf_range(0.95, 1.05)
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
