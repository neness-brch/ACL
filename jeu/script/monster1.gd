extends Area2D

@export var monster_speed: float = 100.0

@export var monster_id: String = "summer_monster_1"

@export_file("*.tscn") var battle_scene: String = "res://scenes/battle3.tscn"

@onready var monster_sprite: AnimatedSprite2D = $AnimatedSprite2D

var player: Player = null
var chasing := false
var battle_started := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	$ContactZone.body_entered.connect(
	_on_contact_zone_body_entered
)
	var defeated := GameState.is_monster_defeated(monster_id)


	if defeated:
		queue_free()
		return
	#monster_sprite.play("idle_south")


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	if battle_started:
		return

	player = body as Player

	if player == null:
		return

	chasing = true


func _on_body_exited(body: Node2D) -> void:
	if body == player and not battle_started:
		player = null
		chasing = false
		#monster_sprite.play("idle_south")


func _process(_delta: float) -> void:
	if chasing and player != null and not battle_started:
		move_towards_player(player)


func move_towards_player(target: Player) -> void:

	
	var direction: Vector2 = global_position.direction_to(
		target.global_position
	)

	if abs(direction.x) > abs(direction.y):
		#monster_sprite.play("walk_west")
		monster_sprite.flip_h = direction.x > 0

	else:
		monster_sprite.flip_h = false

		#if direction.y < 0:
			#monster_sprite.play("walk_north")
		#else:
			#monster_sprite.play("walk_south")

	var delta: float = get_process_delta_time()
	global_position += direction * monster_speed * delta
	
func _on_contact_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameState.save_return_position(body.global_position)
		start_battle()


func start_battle() -> void:
	if battle_started:
		return

	battle_started = true
	chasing = false

	monster_sprite.stop()

	GameState.pending_battle_monster_id = monster_id

	get_tree().call_deferred("change_scene_to_file", battle_scene)
