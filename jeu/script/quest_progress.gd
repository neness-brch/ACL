extends Control

@export var fall_quest_id: String = "fall_quest"
@export var summer_quest_id: String = "summer_quest"

@export var fall_icon: Texture2D
@export var summer_icon: Texture2D

@onready var progress_text: Label = $HBoxContainer/ProgressText
@onready var quest_icon: TextureRect = $HBoxContainer/TextureRect

var current_quest_id: String = ""


func _ready() -> void:
	GameState.quest_active_changed.connect(_on_quest_active_changed)
	GameState.quest_progress_changed.connect(_on_quest_progress_changed)

	update_progress()


func update_progress() -> void:

	if GameState.is_quest_active(summer_quest_id):
		current_quest_id = summer_quest_id
		quest_icon.texture = summer_icon

	elif GameState.is_quest_active(fall_quest_id):
		current_quest_id = fall_quest_id
		quest_icon.texture = fall_icon

	else:
		current_quest_id = ""
		visible = false
		return

	var current: int = GameState.get_quest_progress(current_quest_id)
	var target: int = GameState.get_quest_target(current_quest_id)

	progress_text.text = str(current) + " / " + str(target)

	visible = true


func _on_quest_active_changed(
	_changed_quest_id: String,
	_active: bool
) -> void:
	update_progress()


func _on_quest_progress_changed(
	_changed_quest_id: String,
	_current: int,
	_target: int
) -> void:
	update_progress()
