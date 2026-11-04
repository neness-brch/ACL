extends CharacterBody2D
class_name Player
signal HealthChanged

const SPEED = 300.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var original_sprite_scale: Vector2 = animated_sprite.scale
@export var max_health = 100
@onready var current_health: int = max_health
@export var dialogue_box: DialogueBox

func _physics_process(_delta: float) -> void:
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
		# Marche de profil : ton animation actuelle.
		animation_name = "idle"
		animated_sprite.flip_h = direction.x > 0
	elif direction.y < 0:
		animation_name = "walk_up"
		animated_sprite.flip_h = false
	else:
		animation_name = "walk_down"
		animated_sprite.flip_h = false

	# Adapte la taille des nouvelles images à celle des anciennes.
	var reference_texture = animated_sprite.sprite_frames.get_frame_texture("idle", 0)
	var current_texture = animated_sprite.sprite_frames.get_frame_texture(animation_name, 0)

	var size_ratio: float = float(reference_texture.get_height()) / float(current_texture.get_height())
	if animation_name == "walk_up" or animation_name == "walk_down":
		animated_sprite.scale = original_sprite_scale * size_ratio * Vector2(1.25, 1.15)
	else:
		animated_sprite.scale = original_sprite_scale * size_ratio
	animated_sprite.play(animation_name)
