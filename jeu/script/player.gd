extends CharacterBody2D
class_name Player
signal HealthChanged
signal cinematic_arrived

const SPEED = 300.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var original_sprite_scale: Vector2 = animated_sprite.scale
@export var max_health = 100
@onready var current_health: int = max_health
@export var dialogue_box: DialogueBox
var cinematic_mode := false
var cinematic_target: Node2D = null
var cinematic_stop_distance: float = 35.0
var cinematic_arrived_flag := false
var cinematic_locked := false


func _ready() -> void:
	add_to_group("player")

func _physics_process(_delta: float) -> void:
	
	if cinematic_locked:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	if cinematic_mode:
		cinematic_movement(_delta)
		return
	
	if dialogue_box != null and dialogue_box.dialogue_active:
		velocity = Vector2.ZERO
		animated_sprite.pause()
		move_and_slide()
		return

	var direction = Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down"
	)

	velocity = direction * SPEED
	move_and_slide()

	if direction == Vector2.ZERO:
		animated_sprite.pause()
		return

	var animation_name: String

	if direction.x != 0:
		animation_name = "idle"
		animated_sprite.flip_h = direction.x > 0
	elif direction.y < 0:
		animation_name = "walk_up"
		animated_sprite.flip_h = false
	else:
		animation_name = "walk_down"
		animated_sprite.flip_h = false

	var reference_texture = animated_sprite.sprite_frames.get_frame_texture("idle", 0)
	var current_texture = animated_sprite.sprite_frames.get_frame_texture(animation_name, 0)

	var size_ratio: float = float(reference_texture.get_height()) / float(current_texture.get_height())
	if animation_name == "walk_up" or animation_name == "walk_down":
		animated_sprite.scale = original_sprite_scale * size_ratio * Vector2(1.25, 1.15)
	else:
		animated_sprite.scale = original_sprite_scale * size_ratio
	animated_sprite.play(animation_name)
	
func start_cinematic_approach(target: Node2D) -> void:
	cinematic_mode = true
	cinematic_target = target
	cinematic_arrived_flag = false

	velocity = Vector2.ZERO

	update_cinematic_direction()

	animated_sprite.play("walk_west")


func update_cinematic_direction() -> void:
	if cinematic_target == null:
		return

	var direction = global_position.direction_to(
		cinematic_target.global_position
	)

	if abs(direction.x) > abs(direction.y):
		if direction.x < 0:
			animated_sprite.play("walk_west")
		else:
			animated_sprite.play("walk_east")
	else:
		if direction.y < 0:
			animated_sprite.play("walk_north")
		else:
			animated_sprite.play("walk_south")


func cinematic_movement(delta: float) -> void:
	if cinematic_target == null:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var distance = global_position.distance_to(
		cinematic_target.global_position
	)

	if distance <= cinematic_stop_distance:
		velocity = Vector2.ZERO
		move_and_slide()

		if not cinematic_arrived:
			cinematic_arrived_flag = true
			animated_sprite.play("idle_west")
			cinematic_mode = false
			cinematic_target = null
			emit_signal("cinematic_arrived")

	return

	var direction = global_position.direction_to(
		cinematic_target.global_position
	)

	velocity = direction * SPEED
	move_and_slide()
	
func prepare_for_princess() -> void:
	velocity = Vector2.ZERO
	animated_sprite.play("walk")
