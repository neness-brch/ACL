extends CharacterBody2D

const SPEED = 200.0

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(_delta: float) -> void:

	# Déplacements avec les flèches et ZQSD
	var direction = Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
        "ui_down"
	)

	# Déplacement du personnage
	velocity = direction * SPEED
	move_and_slide()

	# Gestion des animations (noms inversés)
	if direction == Vector2.ZERO:
		animated_sprite.play("walk")
	else:
		animated_sprite.play("idle")

	# Orientation du personnage
	if direction.x < 0:
		animated_sprite.flip_h = true
	elif direction.x > 0:
		animated_sprite.flip_h = false
