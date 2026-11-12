extends Area2D

@onready var princess_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var cinematic_bars = $"../CinematicBars"
@onready var dialogue_box: DialogueBox = $"../CanvasLayer/BoiteDialogues"
@export var princess_portrait: Texture2D

var sequence_started := false
var princess_speed := 100.0
var stop_distance := 80.0

var current_player: Player = null

var princess_dialogue: Array[Dictionary] = [
	{"text": "heyyyyyy youuuuuuu", "speaker": "princess"},
	{"text": "it's been so long !", "speaker": "princess"},
	{"text": "told you we would meet again !", "speaker": "princess"},
	{"text": "what took you so long ???", "speaker": "princess"},
	{"text": "you know I was waiting for you...", "speaker": "princess"},
	{"text": "especially since, well...we were separated", "speaker": "princess"},
	{"text": "but we're reunited now and that's all that matters !", "speaker": "princess"},
	{"text": "aah...", "speaker": "princess"},
	{"text": "it's a nice night, isn't it ?", "speaker": "princess"},
	{"text": "I could spend hours just staying here, listening to the sound of the waves...", "speaker": "princess"},
	{"text": "really relaxing, you should try !", "speaker": "princess"},
	{"text": "...", "speaker": "princess"},
	{"text": "...", "speaker": "princess"},
	{"text": "you know, when I first met you, I immediately knew we'd get along !", "speaker": "princess"},
	{"text": "ever since, I haven't regretted a single moment we spent together.", "speaker": "princess"},
	{"text": "and here we are, finally together, like the good old times !", "speaker": "princess"},
	{"text": "...", "speaker": "princess"},
	{"text": "...", "speaker": "princess"},
	{"text": "you would always tell me you would bring me to the other side of the world.", "speaker": "princess"},
	{"text": "go somewhere where nothing looks like the world we know it.", "speaker": "princess"},
	{"text": "and here we are...", "speaker": "princess"},
	{"text": "isn't that wonderful ? haha", "speaker": "princess"},
	{"text": "...", "speaker": "princess"},
	{"text": "...", "speaker": "princess"},
	{"text": "hey, there's something important I need to tell you.", "speaker": "princess"},
	{"text": "...", "speaker": "princess"},
	{"text": "don't look at me like this !", "speaker": "princess"},
	{"text": "hey !", "speaker": "princess"},
	{"text": "who caaaaares, nothing of this is real !", "speaker": "princess"},
	{"text": "did you notice that at least ???", "speaker": "princess"},
	{"text": "but, I don't know if you're ready to hear this.", "speaker": "princess"},
	{"text": "...", "speaker": "princess"},
	{"text": "I'm sorry but I must tell you.", "speaker": "princess"},
	{"text": "...", "speaker": "princess"},
	{"text": "since the last time, I've been--", "speaker": "princess"}
]


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	princess_sprite.play("idle_north")


func _on_body_entered(body: Node2D) -> void:
	if sequence_started:
		return

	if not body.is_in_group("player"):
		return

	var player := body as Player
	if player == null:
		return

	sequence_started = true
	current_player = player

	set_deferred("monitoring", false)

	player.cinematic_locked = true
	player.velocity = Vector2.ZERO
	player.animated_sprite.pause()

	princess_sprite.play("idle_west")

	await get_tree().create_timer(1.5).timeout

	await cinematic_bars.show_bars()

	await move_towards_player(player)

	princess_sprite.play("idle_west")
	dialogue_box.start_dialogue_with_interruption(
	prepare_dialogue(),
	princess_dialogue.size() - 1
)

func prepare_dialogue() -> Array[Dictionary]:
	var prepared_dialogue: Array[Dictionary] = []

	for message in princess_dialogue:
		var prepared_message: Dictionary = message.duplicate(true)

		if message["speaker"] == "princess":
			prepared_message["portrait"] = princess_portrait

		prepared_dialogue.append(prepared_message)

	return prepared_dialogue

func move_towards_player(player: Player) -> void:

	while true:

		var distance: float = global_position.distance_to(player.global_position)

		if distance <= stop_distance + 1.0:
			break

		var direction: Vector2 = global_position.direction_to(player.global_position)

		if abs(direction.x) > abs(direction.y):
			princess_sprite.play("walk_west")
			princess_sprite.flip_h = direction.x > 0
		else:
			princess_sprite.flip_h = false

			if direction.y < 0:
				princess_sprite.play("walk_north")
			else:
				princess_sprite.play("walk_south")

		var delta: float = get_process_delta_time()
		var movement: float = minf(princess_speed * delta, distance - stop_distance)

		global_position += direction * movement

		await get_tree().process_frame

	princess_sprite.play("idle_west")


func _on_dialogue_finished() -> void:
	get_tree().change_scene_to_file("res://scenes/knighthouse.tscn")
	if current_player != null:
		current_player.cinematic_locked = false
		current_player = null
		
