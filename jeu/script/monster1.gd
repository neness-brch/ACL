
extends Area2D

@export var monster_speed: float = 125.0
@export var return_speed: float = 90.0

@export var monster_id: String = "summer_monster_1"

@export_file("*.tscn") var battle_scene: String = "res://scenes/battle.tscn"

@onready var monster_sprite: AnimatedSprite2D = $AnimatedSprite2D

var player: Player = null
var chasing := false
var returning := false
var battle_started := false

var initial_position: Vector2


func _ready() -> void:
	initial_position = global_position

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	$ContactZone.body_entered.connect(
		_on_contact_zone_body_entered
	)

	var defeated := GameState.is_monster_defeated(monster_id)

	if defeated:
		queue_free()
		return


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	if battle_started:
		return

	player = body as Player

	if player == null:
		return

	chasing = true
	returning = false


func _on_body_exited(body: Node2D) -> void:
	if body == player and not battle_started:
		player = null
		chasing = false
		returning = true


func _process(delta: float) -> void:
	if battle_started:
		return

	if chasing and player != null:
		move_towards_player(player, delta)

	elif returning:
		return_to_initial_position(delta)


func move_towards_player(target: Player, delta: float) -> void:
	var direction: Vector2 = global_position.direction_to(
		target.global_position
	)

	if abs(direction.x) > abs(direction.y):
		monster_sprite.flip_h = direction.x > 0
	else:
		monster_sprite.flip_h = false

	global_position += direction * monster_speed * delta


func return_to_initial_position(delta: float) -> void:
	var distance := global_position.distance_to(initial_position)

	if distance < 2.0:
		global_position = initial_position
		returning = false
		return

	var direction := global_position.direction_to(initial_position)

	if abs(direction.x) > abs(direction.y):
		monster_sprite.flip_h = direction.x > 0
	else:
		monster_sprite.flip_h = false

	global_position += direction * return_speed * delta


func _on_contact_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameState.save_return_position(body.global_position)
		start_battle()


func start_battle() -> void:
	if battle_started:
		return

	battle_started = true
	chasing = false
	returning = false

	monster_sprite.stop()

	GameState.pending_battle_monster_id = monster_id
	GameState.pending_battle_return_scene = get_tree().current_scene.scene_file_path

	get_tree().call_deferred("change_scene_to_file", battle_scene)
