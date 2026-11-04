extends Node2D

enum BattleState {
	MAIN_MENU,
	FIGHT_MENU,
	OBJECTS_MENU,
	PLAYER_ANIMATION,
	ENEMY_TURN,
	DIALOGUE,
	VICTORY,
	DEFEAT
}

var state: BattleState = BattleState.MAIN_MENU

# -------------------------
# DONNÉES : ATTAQUES ET OBJETS
# -------------------------

# Pour ajouter une attaque :
#   1. l'ajouter ici,
#   2. ajouter son cas dans use_attack(),
#   3. la débloquer avec GameState.unlock_attack("id").
const ATTACKS := {
	"sharp_blade": {"name": "SHARP BLADE"},
	"intimidate": {"name": "INTIMIDATE"},
	"special_attack" : {"name": "SPECIAL ATTACK"}
}

const ITEMS := {
	"health_potion": {"name": "HEALTH POTION", "heal_ratio": 0.5},
	"cherry_jam": {"name": "CHERRY JAM", "heal_ratio": 0.2},
}



var hero_max_hp := 100
var hero_hp := 100

@export var monster_id: String = "monster_1"
@export var monster_max_hp: int = 100
@export var monster_damage_min: int = 10
@export var monster_damage_max: int = 15
@export_range(0.01, 1.0) var monster_start_health_ratio: float = 1.0

var monster_hp: int = 100

var monster_attack_multiplier := 1.0


const SLOT_COUNT := 4 
const COLUMNS := 2    

@export_group("Menu layout")
@export var slot_spacing := Vector2(520, 50)
@export var page_label_offset := Vector2(380, 100)
@export_group("")


var main_selection := 0
var fight_selection := 0
var object_selection := 0
var object_page := 0

var shown_attacks: Array = []   
var shown_items: Array = []    

var fight_slots: Array[Label] = []
var object_slots: Array[Label] = []
var page_label: Label

var fight_arrow_offset := Vector2.ZERO
var object_arrow_offset := Vector2.ZERO

@onready var hero = $Player
@onready var monster = $Opponent

@onready var hero_health_bar: ProgressBar = $PlayerUI/HealthBar
@onready var monster_health_bar: ProgressBar = $OpponentUI/HealthBar

@onready var intimidate_arrow = $IntimidateArrow

@onready var battle_menu = $CanvasLayer/BattleMenu
@onready var fight_menu = $CanvasLayer/FightMenu
@onready var objects_menu = $CanvasLayer/ObjectsMenu

@onready var main_arrow = $CanvasLayer/BattleMenu/Arrow
@onready var fight_arrow = $CanvasLayer/FightMenu/Arrow
@onready var objects_arrow = $CanvasLayer/ObjectsMenu/Arrow

@onready var battle_dialogue = $CanvasLayer/BattleDialogue
@onready var battle_dialogue_text = $CanvasLayer/BattleDialogue/Text


func _ready():
	monster_hp = int(round(monster_max_hp * monster_start_health_ratio))
	var hero_fill = hero_health_bar.get_theme_stylebox("fill").duplicate()
	var monster_fill = monster_health_bar.get_theme_stylebox("fill").duplicate()

	hero_health_bar.add_theme_stylebox_override("fill", hero_fill)
	monster_health_bar.add_theme_stylebox_override("fill", monster_fill)

	hero_health_bar.max_value = hero_max_hp
	hero_health_bar.value = hero_hp

	monster_health_bar.max_value = monster_max_hp
	monster_health_bar.value = monster_hp

	update_health_bar_color(hero_health_bar)
	update_health_bar_color(monster_health_bar)

	intimidate_arrow.visible = false
	battle_dialogue.visible = false

	fight_slots = build_slots(fight_menu, fight_arrow)
	object_slots = build_slots(objects_menu, objects_arrow)

	fight_arrow_offset = fight_arrow.position - fight_slots[0].position
	object_arrow_offset = objects_arrow.position - object_slots[0].position

	page_label = create_page_label()

	show_main_menu()


func _process(_delta):

	if state == BattleState.MAIN_MENU:
		handle_main_menu()

	elif state == BattleState.FIGHT_MENU:
		handle_fight_menu()

	elif state == BattleState.OBJECTS_MENU:
		handle_objects_menu()


func build_slots(menu: Node, arrow: Node) -> Array[Label]:
	var slots: Array[Label] = []
	var template: Label = null

	for child in menu.get_children():
		if child is Label and child != arrow:
			if template == null:
				template = child
			else:
				child.queue_free()

	if template == null:
		push_error("Aucun Label modèle dans le menu : " + str(menu.name))
		return slots

	var origin := template.position

	template.clip_text = true
	template.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	slots.append(template)

	for i in range(1, SLOT_COUNT):
		var copy := template.duplicate() as Label
		menu.add_child(copy)
		slots.append(copy)

	for i in SLOT_COUNT:
		slots[i].position = origin + grid_offset(i)
		slots[i].visible = false

	return slots


func create_page_label() -> Label:
	var label := object_slots[0].duplicate() as Label
	label.position = object_slots[0].position + page_label_offset
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.visible = false
	objects_menu.add_child(label)
	return label

func grid_offset(index: int) -> Vector2:
	var column := index % COLUMNS
	var row := floori(float(index) / COLUMNS)

	return Vector2(
		column * slot_spacing.x,
		row * slot_spacing.y
	)


func move_grid_selection(current: int, count: int) -> int:
	var column := current % COLUMNS

	if Input.is_action_just_pressed("battle_left") and column == 1:
		return current - 1

	if Input.is_action_just_pressed("battle_right") and column == 0 and current + 1 < count:
		return current + 1

	if Input.is_action_just_pressed("battle_up") and current - COLUMNS >= 0:
		return current - COLUMNS

	if Input.is_action_just_pressed("battle_down") and current + COLUMNS < count:
		return current + COLUMNS

	return current

func handle_main_menu():

	if Input.is_action_just_pressed("battle_left"):
		main_selection = 0
		update_main_arrow()

	elif Input.is_action_just_pressed("battle_right"):
		main_selection = 1
		update_main_arrow()

	elif Input.is_action_just_pressed("battle_confirm"):

		if main_selection == 0:
			show_fight_menu()
		else:
			show_objects_menu()


func update_main_arrow():

	if main_selection == 0:
		main_arrow.position = Vector2(60, 35)

	else:
		main_arrow.position = Vector2(580, 35)


func show_main_menu():
	state = BattleState.MAIN_MENU

	battle_menu.visible = true
	fight_menu.visible = false
	objects_menu.visible = false

	update_main_arrow()


func show_fight_menu():
	state = BattleState.FIGHT_MENU

	battle_menu.visible = false
	fight_menu.visible = true
	objects_menu.visible = false

	fight_selection = 0
	refresh_fight_menu()


func refresh_fight_menu() -> void:
	shown_attacks = []

	for attack_id in GameState.unlocked_attacks:
		if ATTACKS.has(attack_id):
			shown_attacks.append(attack_id)

		if shown_attacks.size() >= SLOT_COUNT:
			break

	for i in SLOT_COUNT:
		var slot_visible := i < shown_attacks.size()
		fight_slots[i].visible = slot_visible

		if slot_visible:
			fight_slots[i].text = ATTACKS[shown_attacks[i]]["name"]

	fight_selection = clampi(fight_selection, 0, maxi(shown_attacks.size() - 1, 0))
	update_fight_arrow()


func update_fight_arrow():
	fight_arrow.position = fight_slots[fight_selection].position + fight_arrow_offset


func handle_fight_menu():

	var new_selection := move_grid_selection(fight_selection, shown_attacks.size())

	if new_selection != fight_selection:
		fight_selection = new_selection
		update_fight_arrow()

	if Input.is_action_just_pressed("battle_escape"):
		show_main_menu()

	elif Input.is_action_just_pressed("battle_confirm"):

		if not shown_attacks.is_empty():
			use_attack(shown_attacks[fight_selection])


func use_attack(attack_id: String) -> void:
	match attack_id:
		"sharp_blade":
			sharp_blade()

		"intimidate":
			intimidate()

		"special_attack":
			special_attack()


func show_objects_menu():
	state = BattleState.OBJECTS_MENU

	battle_menu.visible = false
	fight_menu.visible = false
	objects_menu.visible = true

	object_page = 0
	object_selection = 0
	refresh_objects_menu()


# Objets possédés (quantité > 0), dans l'ordre de la table ITEMS
func get_usable_items() -> Array:
	var result: Array = []

	for item_id in ITEMS:
		if GameState.has_item(item_id):
			result.append(item_id)

	return result


func get_page_count() -> int:
	return maxi(1, ceili(get_usable_items().size() / float(SLOT_COUNT)))


func refresh_objects_menu() -> void:
	var all_items := get_usable_items()
	var page_count := maxi(1, ceili(all_items.size() / float(SLOT_COUNT)))

	object_page = clampi(object_page, 0, page_count - 1)

	var start := object_page * SLOT_COUNT
	shown_items = all_items.slice(start, start + SLOT_COUNT)

	for i in SLOT_COUNT:
		var slot_visible := i < shown_items.size()
		object_slots[i].visible = slot_visible

		if slot_visible:
			var item_id: String = shown_items[i]
			object_slots[i].text = "%s x%d" % [
				ITEMS[item_id]["name"],
				GameState.get_item_count(item_id)
			]

	# Aucun objet : message à la place de la liste, pas de flèche
	if all_items.is_empty():
		object_slots[0].visible = true
		object_slots[0].text = "No items"

	objects_arrow.visible = not shown_items.is_empty()

	object_selection = clampi(object_selection, 0, maxi(shown_items.size() - 1, 0))
	update_object_arrow()

	page_label.visible = page_count > 1
	page_label.text = "Q   %d / %d   D" % [object_page + 1, page_count]


func update_object_arrow():
	objects_arrow.position = object_slots[object_selection].position + object_arrow_offset


func change_object_page(direction: int) -> void:
	var new_page := clampi(object_page + direction, 0, get_page_count() - 1)

	if new_page == object_page:
		return

	object_page = new_page
	object_selection = 0
	refresh_objects_menu()


func handle_objects_menu():

	if Input.is_action_just_pressed("battle_escape"):
		show_main_menu()
		return

	if shown_items.is_empty():
		return

	var new_selection := move_grid_selection(object_selection, shown_items.size())

	if new_selection != object_selection:
		object_selection = new_selection
		update_object_arrow()

	if Input.is_action_just_pressed("battle_page_prev"):
		change_object_page(-1)

	elif Input.is_action_just_pressed("battle_page_next"):
		change_object_page(1)

	elif Input.is_action_just_pressed("battle_confirm"):
		use_item(shown_items[object_selection])


func use_item(item_id: String) -> void:

	if not ITEMS.has(item_id):
		return

	if not GameState.has_item(item_id):
		return

	if hero_hp >= hero_max_hp:
		return

	state = BattleState.PLAYER_ANIMATION
	hide_menus()

	GameState.remove_item(item_id, 1)

	var healing := int(hero_max_hp * ITEMS[item_id]["heal_ratio"])

	hero_hp = min(
		hero_hp + healing,
		hero_max_hp
	)

	await animate_health_bar(
		hero_health_bar,
		hero_health_bar.value,
		hero_hp
	)

	await get_tree().create_timer(0.5).timeout

	enemy_turn()


func hide_menus():
	battle_menu.visible = false
	fight_menu.visible = false
	objects_menu.visible = false


func sharp_blade():

	state = BattleState.PLAYER_ANIMATION
	hide_menus()

	var damage := randi_range(20, 24)

	monster_hp -= damage
	monster_hp = max(monster_hp, 0)

	await flash_monster()

	await animate_health_bar(
		monster_health_bar,
		monster_health_bar.value,
		monster_hp
	)

	if monster_hp <= 0:
		victory()
		return

	await get_tree().create_timer(0.4).timeout

	enemy_turn()


func flash_monster():

	for i in range(3):

		monster.modulate = Color(1.0, 0.45, 0.45)

		await get_tree().create_timer(0.10).timeout

		monster.modulate = Color.WHITE

		await get_tree().create_timer(0.10).timeout


func animate_health_bar(
	bar: ProgressBar,
	from_value: float,
	to_value: float
):
	var tween := create_tween()

	tween.tween_method(
		func(value):
			bar.value = value
			update_health_bar_color(bar),
		from_value,
		to_value,
		0.4
	)

	await tween.finished


func intimidate():

	state = BattleState.PLAYER_ANIMATION
	hide_menus()

	monster_attack_multiplier *= 0.75

	await show_intimidate_animation()

	await get_tree().create_timer(0.4).timeout

	enemy_turn()
	
func special_attack():

	state = BattleState.PLAYER_ANIMATION
	hide_menus()

	monster_hp = monster_hp*0.8

	await flash_monster()

	await get_tree().create_timer(0.4).timeout

	enemy_turn()


func show_intimidate_animation():

	intimidate_arrow.text = "↓"
	intimidate_arrow.visible = true

	for i in range(3):

		intimidate_arrow.modulate.a = 1.0
		await get_tree().create_timer(0.15).timeout

		intimidate_arrow.modulate.a = 0.0
		await get_tree().create_timer(0.15).timeout

	intimidate_arrow.visible = false


func enemy_turn():

	state = BattleState.ENEMY_TURN

	await get_tree().create_timer(0.6).timeout

	var base_damage := randi_range(monster_damage_min, monster_damage_max)
	var damage := int(
		base_damage * monster_attack_multiplier
	)

	hero_hp -= damage
	hero_hp = max(hero_hp, 0)

	await flash_hero()

	await animate_health_bar(
		hero_health_bar,
		hero_health_bar.value,
		hero_hp
	)

	if hero_hp <= 0:
		defeat()
		return

	await get_tree().create_timer(0.5).timeout

	show_main_menu()


func flash_hero():

	for i in range(3):

		hero.modulate = Color(1.0, 0.45, 0.45)
		await get_tree().create_timer(0.10).timeout

		hero.modulate = Color.WHITE
		await get_tree().create_timer(0.10).timeout

func victory():
	state = BattleState.VICTORY
	hide_menus()
	if not GameState.is_monster_defeated(monster_id):
		GameState.defeat_monster(monster_id)
		GameState.add_quest_progress("fall_quest", 1)

	battle_dialogue.visible = true
	battle_dialogue_text.text = "you won the battle!"

	await get_tree().create_timer(2.5).timeout

	SceneTransition.change_scene("res://maingame.tscn")


func defeat():
	state = BattleState.DEFEAT
	hide_menus()

	battle_dialogue.visible = true
	battle_dialogue_text.text = "game over..."

func update_health_bar_color(bar: ProgressBar):
	var ratio := bar.value / bar.max_value

	var health_color: Color

	if ratio > 0.5:
		health_color = Color.YELLOW.lerp(
			Color.GREEN,
			(ratio - 0.5) * 2.0
		)
	else:
		health_color = Color.RED.lerp(
			Color.YELLOW,
			ratio * 2.0
		)

	var fill_style = bar.get_theme_stylebox("fill")

	if fill_style is StyleBoxFlat:
		fill_style.bg_color = health_color
