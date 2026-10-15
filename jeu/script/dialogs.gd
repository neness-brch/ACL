extends Control
class_name DialogueBox

@export var chars_per_second := 40.0

@onready var label: RichTextLabel = $VBoxContainer/Dialog

var messages: Array[String] = []
var current_message := 0
var dialogue_active := false
var tween: Tween


func _ready():
	visible = false


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

	var duration := label.get_total_character_count() / chars_per_second
	tween = create_tween()
	tween.tween_property(label, "visible_ratio", 1.0, duration)


func _process(_delta):
	if dialogue_active and Input.is_action_just_pressed("next_dialogue"):
		if tween and tween.is_running():
			tween.kill()
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
	dialogue_active = false
	label.text = ""
	messages.clear()
	visible = false
