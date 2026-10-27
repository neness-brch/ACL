extends CharacterBody2D
class_name Player
signal HealthChanged

const SPEED = 300.0

@onready var animated_sprite = $AnimatedSprite2D
@export var max_health = 100
@onready var current_health: int = max_health
@export var dialogue_box: DialogueBox

func _physics_process(_delta: float) -> void:
	if dialogue_box != null and dialogue_box.dialogue_active:
		velocity = Vector2.ZERO
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
		animated_sprite.play("walk")
	else:
		animated_sprite.play("idle")
