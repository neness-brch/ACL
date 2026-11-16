extends Node2D


enum BattleState {
	TARGET_SELECT,
	MAIN_MENU,
	FIGHT_MENU,
	OBJECTS_MENU,
	PLAYER_ANIMATION,
	ENEMY_TURN,
	DIALOGUE,
	VICTORY,
	DEFEAT
}
var state: BattleState = BattleState.TARGET_SELECT

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
	"special_attack": {"name": "SPECIAL ATTACK"}
}

const ITEMS := {
	"health_potion": {"name": "HEALTH POTION", "heal_ratio": 0.5},
	"cherry_jam": {"name": "CHERRY JAM", "heal_ratio": 0.2},
}

const MONSTER_COUNT := 2


@export_file("*.tscn") var return_scene: String = "res://zone_2.tscn"

@export var quest_id: String = ""

@export var monster_names: Array[String] = ["Monster1", "Monster2"]

@export var highlight_offsets: Array[Vector2] = [Vector2.ZERO, Vector2.ZERO]

@export var monster_id: String = "monster_1"
@export var monster_max_hp: int = 100
@export var monster_damage_min: int = 10
@export var monster_damage_max: int = 15
@export_range(0.01, 1.0) var monster_start_health_ratio: float = 1.0

@export_group("Monster 2")
@export var monster2_id: String = ""
@export var monster2_max_hp: int = 100
@export var monster2_damage_min: int = 10
@export var monster2_damage_max: int = 15
@export_range(0.01, 1.0) var monster2_start_health_ratio: float = 1.0
@export_group("")

@export_group("Menu layout")
@export var slot_spacing := Vector2(520, 50)
@export var slot_text_width := 460.0
@export var page_label_offset := Vector2(380, 100)
@export_group("")
 
var hero_max_hp := 100
var hero_hp := 100

var m_ids: Array[String] = []
var m_max_hp: Array[int] = []
var m_hp: Array[int] = []
var m_damage_min: Array[int] = []
var m_damage_max: Array[int] = []
var m_attack_mult: Array[float] = [1.0, 1.0]


const SLOT_COUNT := 4
const COLUMNS := 2

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
var target: int = 0

@onready var hero = $Player

@onready var m_sprites: Array = [$Opponent, $Opponent2]
@onready var m_bars: Array = [$OpponentUI/HealthBar, $Opponent2UI/HealthBar]
@onready var m_arrows: Array = [$IntimidateArrow, $IntimidateArrow2]

@onready var target_highlight: ColorRect = $FondBlanc

@onready var hero_health_bar: ProgressBar = $PlayerUI/HealthBar

@onready var battle_menu = $CanvasLayer/BattleMenu
@onready var fight_menu = $CanvasLayer/FightMenu
@onready var objects_menu = $CanvasLayer/ObjectsMenu

@onready var main_arrow = $CanvasLayer/BattleMenu/Arrow
@onready var fight_arrow = $CanvasLayer/FightMenu/Arrow
@onready var objects_arrow = $CanvasLayer/ObjectsMenu/Arrow

@onready var battle_dialogue = $CanvasLayer/BattleDialogue
@onready var battle_dialogue_text = $CanvasLayer/BattleDialogue/Text


func _ready():
	monster_id = GameState.consume_battle_monster_id(monster_id)
	hero_hp = GameState.player_hp

	setup_monsters()

	var hero_fill = hero_health_bar.get_theme_stylebox("fill").duplicate()
	hero_health_bar.add_theme_stylebox_override("fill", hero_fill)
	hero_health_bar.max_value = hero_max_hp
	hero_health_bar.value = hero_hp
	update_health_bar_color(hero_health_bar)

	battle_dialogue.visible = false
	target_highlight.visible = false

	fight_slots = build_slots(fight_menu, fight_arrow)
	object_slots = build_slots(objects_menu, objects_arrow)

	fight_arrow_offset = fight_arrow.position - fight_slots[0].position
	object_arrow_offset = objects_arrow.position - object_slots[0].position

	page_label = create_page_label()

	show_target_select()


func setup_monsters() -> void:
	m_ids = [monster_id, monster2_id]
	m_max_hp = [monster_max_hp, monster2_max_hp]
	m_damage_min = [monster_damage_min, monster2_damage_min]
	m_damage_max = [monster_damage_max, monster2_damage_max]
	m_attack_mult = [1.0, 1.0]
	m_hp = [
		maxi(int(round(monster_max_hp * monster_start_health_ratio)), 1),
		maxi(int(round(monster2_max_hp * monster2_start_health_ratio)), 1)
	]

	for i in MONSTER_COUNT:
		var bar: ProgressBar = m_bars[i]
		var fill = bar.get_theme_stylebox("fill").duplicate()
		bar.add_theme_stylebox_override("fill", fill)
		bar.max_value = m_max_hp[i]
		bar.value = m_hp[i]
		update_health_bar_color(bar)

		var arrow: Label = m_arrows[i]
		arrow.visible = false


func _process(_delta):

	if state == BattleState.TARGET_SELECT:
		handle_target_select()

	elif state == BattleState.MAIN_MENU:
		handle_main_menu()

	elif state == BattleState.FIGHT_MENU:
		handle_fight_menu()

	elif state == BattleState.OBJECTS_MENU:
		handle_objects_menu()


func is_alive(index: int) -> bool:
	return m_hp[index] > 0


func get_alive_monsters() -> Array[int]:
	var result: Array[int] = []

	for i in MONSTER_COUNT:
		if m_hp[i] > 0:
			result.append(i)

	return result


func all_monsters_dead() -> bool:
	return get_alive_monsters().is_empty()


func monster_position(index: int) -> Vector2:
	return m_sprites[index].get_global_transform().origin


#func update_highlight() -> void:
	#target_highlight.global_position = monster_position(target) + highlight_offsets[target]
	#target_highlight.visible = true
	
func update_highlight() -> void:
	target_highlight.global_position = (
		monster_position(target)
		- target_highlight.size / 2
		+ highlight_offsets[target]
	)
	target_highlight.visible = true


func select_target_side(go_right: bool) -> void:
	if get_alive_monsters().size() < 2:
		return

	var left_index := 0

	if monster_position(0).x > monster_position(1).x:
		left_index = 1

	var new_target := left_index

	if go_right:
		new_target = 1 - left_index

	if new_target != target:
		target = new_target
		update_highlight()



func show_target_select() -> void:
	state = BattleState.TARGET_SELECT

	battle_menu.visible = false
	fight_menu.visible = false
	objects_menu.visible = false

	var alive := get_alive_monsters()

	if alive.is_empty():
		return

	if not alive.has(target):
		target = alive[0]

	update_highlight()

	# Un seul monstre restant : il n'y a plus de choix à faire
	if alive.size() == 1:
		show_main_menu()


func handle_target_select() -> void:

	if Input.is_action_just_pressed("battle_left"):
		select_target_side(false)

	elif Input.is_action_just_pressed("battle_right"):
		select_target_side(true)

	elif Input.is_action_just_pressed("battle_confirm"):
		show_main_menu()


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
	template.custom_minimum_size.x = slot_text_width
	template.size.x = slot_text_width
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

	elif Input.is_action_just_pressed("battle_escape"):
		if get_alive_monsters().size() > 1:
			show_target_select()

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

	update_highlight()
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
		show_message("your HP is already full!")
		return

	state = BattleState.PLAYER_ANIMATION
	hide_menus()

	GameState.remove_item(item_id, 1)

	var healing := int(hero_max_hp * ITEMS[item_id]["heal_ratio"])

	update_player_hp(min(
		hero_hp + healing,
		hero_max_hp
	))

	await animate_health_bar(
		hero_health_bar,
		hero_health_bar.value,
		hero_hp
	)

	await get_tree().create_timer(0.5).timeout

	end_hero_turn()


# Affiche brièvement un message, puis rend la main à l'état précédent
func show_message(message: String, duration := 1.2) -> void:
	var previous_state := state

	state = BattleState.DIALOGUE
	battle_dialogue.visible = true
	battle_dialogue_text.text = message

	await get_tree().create_timer(duration).timeout

	battle_dialogue.visible = false
	state = previous_state


func hide_menus():
	battle_menu.visible = false
	fight_menu.visible = false
	objects_menu.visible = false
	target_highlight.visible = false

func sharp_blade():

	state = BattleState.PLAYER_ANIMATION
	hide_menus()

	var t := target
	var damage := randi_range(20, 24)

	await damage_monster(t, damage)

	await show_message(
		"Heroine used SHARP BLADE.\n%s took %d damage." % [monster_names[t], damage]
	)

	await announce_defeat(t)
	end_hero_turn()


func intimidate():

	state = BattleState.PLAYER_ANIMATION
	hide_menus()

	var t := target

	m_attack_mult[t] *= 0.75

	await show_intimidate_animation(t)
	await show_message(
		"Heroine used INTIMIDATE.\n%s's attack was weakened." % monster_names[t]
	)

	await get_tree().create_timer(0.4).timeout

	end_hero_turn()


func special_attack():

	state = BattleState.PLAYER_ANIMATION
	hide_menus()

	var t := target
	var damage := maxi(int(m_hp[t] * 0.2), 1)

	await damage_monster(t, damage)

	await show_message(
		"Heroine used SPECIAL ATTACK.\n%s took %d damage." % [monster_names[t], damage]
	)

	await announce_defeat(t)
	end_hero_turn()


# Retire des PV au monstre, joue l'animation, et le fait disparaître s'il est vaincu
func damage_monster(index: int, amount: int) -> void:
	m_hp[index] = maxi(m_hp[index] - amount, 0)

	await flash_monster(index)

	var bar: ProgressBar = m_bars[index]

	await animate_health_bar(bar, bar.value, m_hp[index])

	if m_hp[index] <= 0:
		await kill_monster(index)


func kill_monster(index: int) -> void:
	var sprite: CanvasItem = m_sprites[index]

	var fade := create_tween()
	fade.tween_property(sprite, "modulate:a", 0.0, 0.5)
	await fade.finished

	sprite.visible = false

	# Masque l'interface du monstre vaincu (barre de vie et éventuel nom)
	var ui = m_bars[index].get_parent()
	ui.visible = false


func announce_defeat(index: int) -> void:
	if m_hp[index] <= 0:
		await show_message("%s was defeated!" % monster_names[index])


func flash_monster(index: int) -> void:
	var sprite: CanvasItem = m_sprites[index]

	for i in range(3):

		sprite.modulate = Color(1.0, 0.45, 0.45)

		await get_tree().create_timer(0.10).timeout

		sprite.modulate = Color.WHITE

		await get_tree().create_timer(0.10).timeout


# Flèche d'intimidation au-dessus du monstre ciblé (une flèche par monstre)
func show_intimidate_animation(index: int) -> void:
	var arrow: Label = m_arrows[index]

	arrow.text = "↓"
	arrow.visible = true

	for i in range(3):

		arrow.modulate.a = 1.0
		await get_tree().create_timer(0.15).timeout

		arrow.modulate.a = 0.0
		await get_tree().create_timer(0.15).timeout

	arrow.visible = false


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


# =========================
# FIN DU TOUR DE L'HÉROÏNE, TOUR DES MONSTRES
# =========================

func end_hero_turn() -> void:

	if all_monsters_dead():
		victory()
		return

	await get_tree().create_timer(0.4).timeout

	await enemy_phase()


# Chaque monstre encore en vie attaque l'héroïne : monstre 1 puis monstre 2
func enemy_phase() -> void:

	state = BattleState.ENEMY_TURN

	for i in MONSTER_COUNT:

		if not is_alive(i):
			continue

		await monster_attack(i)

		if hero_hp <= 0:
			defeat()
			return

	await get_tree().create_timer(0.5).timeout

	start_player_turn()


func monster_attack(index: int) -> void:

	await get_tree().create_timer(0.6).timeout

	var base_damage := randi_range(m_damage_min[index], m_damage_max[index])
	var damage := int(base_damage * m_attack_mult[index])

	await show_message(
		"%s attacked Heroine.\nHeroine took %d damage." % [monster_names[index], damage]
	)

	update_player_hp(hero_hp - damage)

	await flash_hero()

	await animate_health_bar(
		hero_health_bar,
		hero_health_bar.value,
		hero_hp
	)


func start_player_turn() -> void:
	show_target_select()


func flash_hero():

	for i in range(3):

		hero.modulate = Color(1.0, 0.45, 0.45)
		await get_tree().create_timer(0.10).timeout

		hero.modulate = Color.WHITE
		await get_tree().create_timer(0.10).timeout


# =========================
# FIN DE COMBAT
# =========================

func victory():
	state = BattleState.VICTORY
	hide_menus()

	var newly_defeated := 0

	for i in MONSTER_COUNT:
		if m_ids[i] != "" and not GameState.is_monster_defeated(m_ids[i]):
			GameState.defeat_monster(m_ids[i])
			newly_defeated += 1

	if quest_id != "" and newly_defeated > 0:
		GameState.add_quest_progress(quest_id, newly_defeated)

	battle_dialogue.visible = true
	battle_dialogue_text.text = "you won the battle!"

	await get_tree().create_timer(2.5).timeout

	SceneTransition.change_scene(return_scene)


func defeat():
	state = BattleState.DEFEAT
	hide_menus()

	battle_dialogue.visible = true
	battle_dialogue_text.text = "game over..."


# =========================
# BARRES DE VIE
# =========================

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


func update_player_hp(new_hp: int) -> void:
	hero_hp = clampi(new_hp, 0, GameState.player_max_hp)
	GameState.player_hp = hero_hp
