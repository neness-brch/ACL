extends CharacterBody2D

const SPEED = 200.0

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(_delta: float) -> void:

	var direction = Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
        "ui_down"
	)

	# Déplacer le personnage
	velocity = direction * SPEED
	move_and_slide()

	# Animations (noms inversés)
	if direction == Vector2.ZERO:
		animated_sprite.play("walk")
	else:
		animated_sprite.play("idle")
