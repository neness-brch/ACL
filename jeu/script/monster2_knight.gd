extends Area2D

@onready var player: Node2D = $"../Player"
@onready var knight: Sprite2D = $Sprite2D
@onready var monster: AnimatedSprite2D = $AnimatedSprite2D
@onready var dialogue_box = $"../CanvasLayer/BoiteDialogues"

var interaction_label: Control
var combat_started: bool = false


func _ready() -> void:
	interaction_label = $"../Guards/InteractionPrompt".duplicate() as Control
	add_child(interaction_label)
	interaction_label.position = knight.position + Vector2(-116, -110)
	interaction_label.hide()

	if GameState.is_monster_defeated("monster_2"):
		monster.hide()
		knight.region_enabled = true
		knight.region_rect = Rect2(
			79.29258, 2.0749948, 234.95468, 327.84918
		)
		knight.scale = Vector2(0.26262656, 0.24069457)
		knight.position.y -= 20.0

	# Collision du chevalier, couché ou debout.
	var knight_height: float = knight.region_rect.size.y * abs(knight.scale.y)
	var knight_feet: Vector2 = knight.position + Vector2(
		0, knight_height / 2.0 - 15.0
	)
	create_obstacle("KnightObstacle", knight_feet, Vector2(60, 30))

	# Le monstre bloque le passage seulement tant qu'il est vivant.
	if not GameState.is_monster_defeated("monster_2"):
		create_obstacle(
			"MonsterObstacle",
			monster.position,
			Vector2(60, 60)
		)

func _process(_delta: float) -> void:
	interaction_label.visible = (
		not combat_started
		and not GameState.is_monster_defeated("monster_2")
		and not dialogue_box.dialogue_active
		and player.global_position.distance_to(knight.global_position) < 160.0
	)


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	if not event.pressed or event.echo:
		return
	if event.physical_keycode != KEY_E:
		return
	if not interaction_label.visible:
		return

	get_viewport().set_input_as_handled()
	start_encounter()


func start_encounter() -> void:
	combat_started = true
	interaction_label.hide()

	# Image du chevalier debout.
	var knight_portrait := AtlasTexture.new()
	knight_portrait.atlas = knight.texture
	knight_portrait.region = Rect2(
		79.29258, 2.0749948, 234.95468, 327.84918
	)

	# Image de l'héroïne.
	var heroine_portrait := AtlasTexture.new()
	heroine_portrait.atlas = load("res://assets/sprite sheets/idle.png")
	heroine_portrait.region = Rect2(0, 0, 46, 55)

	dialogue_box.start_dialogue([
		{
			"text": "Help! This monster is too powerful!",
			"portrait": knight_portrait,
			"speaker": "knight"
		},
		{
			"text": "I've wounded it, but I can't fight anymore.",
			"portrait": knight_portrait,
			"speaker": "knight"
		},
		{
			"text": "Get to safety. I'll finish it off!",
			"portrait": heroine_portrait,
			"speaker": "heroine"
		}
	])

	await dialogue_box.dialogue_finished

	GameState.save_return_position(player.global_position)
	SceneTransition.change_scene("res://scenes/battle2.tscn")
	
func create_obstacle(
	obstacle_name: String,
	obstacle_position: Vector2,
	obstacle_size: Vector2
) -> void:
	var body := StaticBody2D.new()
	body.name = obstacle_name
	body.position = obstacle_position
	body.collision_layer = 1
	body.collision_mask = 0

	var collision := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = obstacle_size
	collision.shape = rectangle

	body.add_child(collision)
	add_child(body)
