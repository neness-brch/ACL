extends Node

signal quest_progress_changed(quest_id: String, current: int, target: int)
signal quest_completed(quest_id: String)
signal quest_active_changed(quest_id: String, active: bool)

var quests_completed: Dictionary = {
	"fall_quest": false
}

var quests_active: Dictionary = {
	"fall_quest": false
}

var dialogues_seen: Dictionary = {}
var tim_needs_escort := false

var quest_progress: Dictionary = {
	"fall_quest": 0
}

var quest_targets: Dictionary = {
	"fall_quest": 3
}


func add_quest_progress(quest_id: String, amount: int = 1):
	if is_quest_completed(quest_id):
		return

	quest_progress[quest_id] = quest_progress.get(quest_id, 0) + amount

	var current: int = quest_progress[quest_id]
	var target: int = quest_targets.get(quest_id, 1)

	if current >= target:
		current = target
		quest_progress[quest_id] = target

	quest_progress_changed.emit(quest_id, current, target)

	if current >= target:
		complete_quest(quest_id)


func get_quest_progress(quest_id: String) -> int:
	return quest_progress.get(quest_id, 0)


func get_quest_target(quest_id: String) -> int:
	return quest_targets.get(quest_id, 1)


func complete_quest(quest_id: String):
	quests_completed[quest_id] = true
	quest_completed.emit(quest_id)


func is_quest_completed(quest_id: String) -> bool:
	return quests_completed.get(quest_id, false)
	
func is_quest_active(quest_id: String) -> bool:
	return quests_active.get(quest_id, false)


func mark_dialogue_seen(dialogue_id: String):
	dialogues_seen[dialogue_id] = true


func has_seen_dialogue(dialogue_id: String) -> bool:
	return dialogues_seen.get(dialogue_id, false)
	
func start_quest(quest_id: String):
	quests_active[quest_id] = true	
	quest_active_changed.emit(quest_id, true)


func end_quest(quest_id: String):
	quests_active[quest_id] = false
	quest_active_changed.emit(quest_id, false)

var inventory: Dictionary = {
	"health_potion": 0
}


func add_item(item_id: String, amount: int = 1):
	inventory[item_id] = inventory.get(item_id, 0) + amount


func remove_item(item_id: String, amount: int = 1) -> bool:
	var current_amount: int = inventory.get(item_id, 0)

	if current_amount < amount:
		return false

	inventory[item_id] = current_amount - amount
	return true


func get_item_count(item_id: String) -> int:
	return inventory.get(item_id, 0)


func has_item(item_id: String) -> bool:
	return get_item_count(item_id) > 0
	
var monsters_defeated: Dictionary = {
	"monster_1": false,
	"monster_2": false,
	"monster_3": false
}

func defeat_monster(monster_id: String):
	monsters_defeated[monster_id] = true


func is_monster_defeated(monster_id: String) -> bool:
	return monsters_defeated.get(monster_id, false)
	
var return_position: Vector2 = Vector2.ZERO
var has_return_position := false


func save_return_position(position: Vector2):
	return_position = position
	has_return_position = true


func consume_return_position() -> Vector2:
	has_return_position = false
	return return_position
