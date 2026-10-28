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
# STATS
# -------------------------

var hero_max_hp := 100
var hero_hp := 100

var monster_max_hp := 100
var monster_hp := 100

var monster_attack_multiplier := 1.0



# -------------------------
# MENU
# -------------------------

var main_selection := 0
var fight_selection := 0
var object_selection := 0


# -------------------------
# NODES
# -------------------------

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

	show_main_menu()
	
func _process(_delta):

	if state == BattleState.MAIN_MENU:
		handle_main_menu()

	elif state == BattleState.FIGHT_MENU:
		handle_fight_menu()

	elif state == BattleState.OBJECTS_MENU:
		handle_objects_menu()
		
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
		
func update_fight_arrow():

	if fight_selection == 0:
		fight_arrow.position = Vector2(60, 35)

	else:
		fight_arrow.position = Vector2(580, 35)
		
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

	update_fight_arrow()


func show_objects_menu():
	state = BattleState.OBJECTS_MENU

	battle_menu.visible = false
	fight_menu.visible = false
	objects_menu.visible = true

	var has_potion := GameState.has_item("health_potion")

	$CanvasLayer/ObjectsMenu/HealthPotionLabel.visible = has_potion
	objects_arrow.visible = has_potion
	
func handle_fight_menu():

	if Input.is_action_just_pressed("battle_left"):
		fight_selection = 0
		update_fight_arrow()

	elif Input.is_action_just_pressed("battle_right"):
		fight_selection = 1
		update_fight_arrow()

	elif Input.is_action_just_pressed("battle_escape"):
		show_main_menu()

	elif Input.is_action_just_pressed("battle_confirm"):

		if fight_selection == 0:
			sharp_blade()

		else:
			intimidate()
			
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

	var base_damage := randi_range(10, 15)

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
		
func handle_objects_menu():

	if Input.is_action_just_pressed("battle_escape"):
		show_main_menu()

	elif Input.is_action_just_pressed("battle_confirm"):

		if GameState.has_item("health_potion"):
			use_health_potion()
		
func use_health_potion():

	if not GameState.has_item("health_potion"):
		return

	if hero_hp >= hero_max_hp:
		return

	state = BattleState.PLAYER_ANIMATION
	hide_menus()

	GameState.remove_item("health_potion", 1)

	var healing := int(hero_max_hp * 0.5)

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

func victory():
	state = BattleState.VICTORY
	hide_menus()
	if not GameState.is_monster_defeated("monster_1"):
		GameState.defeat_monster("monster_1")
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
		# 50% → jaune
		# 100% → vert
		health_color = Color.YELLOW.lerp(
			Color.GREEN,
			(ratio - 0.5) * 2.0
		)
	else:
		# 0% → rouge
		# 50% → jaune
		health_color = Color.RED.lerp(
			Color.YELLOW,
			ratio * 2.0
		)

	var fill_style = bar.get_theme_stylebox("fill")

	if fill_style is StyleBoxFlat:
		fill_style.bg_color = health_color
