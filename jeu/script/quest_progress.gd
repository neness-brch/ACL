extends Control

@export var quest_id: String = "fall_quest"

@onready var progress_text: Label = $HBoxContainer/ProgressText


func _ready() -> void:
	GameState.quest_active_changed.connect(_on_quest_active_changed)
	GameState.quest_progress_changed.connect(_on_quest_progress_changed)
	update_progress()


func update_progress() -> void:
	var current: int = GameState.get_quest_progress(quest_id)
	var target: int = GameState.get_quest_target(quest_id)

	progress_text.text = str(current) + " / " + str(target)
	visible = GameState.is_quest_active(quest_id)


func _on_quest_active_changed(
	changed_quest_id: String,
	_active: bool
) -> void:
	if changed_quest_id == quest_id:
		update_progress()


func _on_quest_progress_changed(
	changed_quest_id: String,
	_current: int,
	_target: int
) -> void:
	if changed_quest_id == quest_id:
		update_progress()
