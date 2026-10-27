extends Control

@export var quest_id: String = "fall_quest"

@onready var progress_text: Label = $HBoxContainer/ProgressText


func _ready():
	GameState.quest_active_changed.connect(_on_quest_active_changed)
	GameState.quest_progress_changed.connect(_on_quest_progress_changed)

	visible = GameState.is_quest_active(quest_id)

	update_progress()


func update_progress():
	var current := GameState.get_quest_progress(quest_id)
	var target := GameState.get_quest_target(quest_id)

	progress_text.text = str(current) + " / " + str(target)


func _on_quest_active_changed(changed_quest_id: String, active: bool):

	if changed_quest_id != quest_id:
		return

	visible = active


func _on_quest_progress_changed(
	changed_quest_id: String,
	current: int,
	target: int
):
	if changed_quest_id != quest_id:
		return

	progress_text.text = str(current) + " / " + str(target)
