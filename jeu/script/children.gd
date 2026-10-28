extends Area2D

@export var npc_id: String = "children"
@onready var monster = $Monster1
@onready var player: Player = $"../Player"
@onready var music_zone: Area2D = $"../Monster1MusicZone"
@onready var normal_music: AudioStreamPlayer = $"../MusicNode/AudioStreamPlayer"
@onready var monster_music: AudioStreamPlayer = $"../MusicNode/MonsterMusic"

var player_nearby := false
var current_dialogue_id: String = ""
var tim_needs_escort := false

@onready var interaction_prompt = $InteractionPrompt
@onready var new_dialogue_bubble = $DialogueBubble
@onready var dialogue_box: DialogueBox = $"../CanvasLayer/BoiteDialogues"

@export var tim_portrait: Texture2D
@export var friend_portrait: Texture2D
@export var monster_portrait: Texture2D


var first_dialogue: Array[Dictionary] = [
	{"text": "tim... are you okay???", "speaker": "friend"},
	{"text": "...", "speaker": "tim"},
	{"text": "i knew we shouldn't have gone so far...", "speaker": "friend"},
	{"text": "your father warned us.", "speaker": "friend"},
	{"text": "I'm so sorry I couldn't save you, Tim...", "speaker": "friend"},
	{"text": "...", "speaker": "tim"},

	{"text": "are you... here to save us?", "speaker": "friend"},
	{"text": "no... this thing is too strong for us.", "speaker": "friend"},
	{"text": "it's gonna kill my family...", "speaker": "friend"},
	{"text": "and then the whole village...", "speaker": "friend"},
	{"text": "and we're next.", "speaker": "friend"},

	{"text": "y-you're not saying anything...", "speaker": "friend"},
	{"text": "I-I suppose you're too scared as well.", "speaker": "friend"},
	{"text": "no...", "speaker": "friend"},
	{"text": "you really want to fight it?", "speaker": "friend"},
	{"text": "you better be qui--", "speaker": "friend"},

	{"text": "Ḧ̸̡́̀̐̽̈͘Ą̶̛̜̦̩̹̩̫̖̤̤͎̂̐H̴̤̉̄̊̈́̍̍̕̚A̷̝̋̐̆͌̾͋̕͠͠A̴̹̟͕͕̟̦͗̅H̴̪̘̜̮̤̥͚̠͉̜͈̋̂̀̓͋̈̿̐̂̚͠Ȃ̶̧̡̻̟̻̰̹̖̳̻̱͕̎̊͋̍̓̾̿̈́̕͝Ḩ̷̙͔̒A̷͚̣͙̪̼̫̜̙͊̏́͛̄͂͗̏̌̐̃͜͝A̵̛̪͓̮̟̝̼̠̒́͊̽̄̇̆̈́A̷̛̛̻͙̼̺̐̌͗͌̏̃̀͂Á̴̘̱̹͚̿̀̓͗̈̾̈́̇̕͝͝ͅȦ̵͓͙͓̺͍͇̌̋̓̊̋̀͘̕A̵͔͔͈͉͌̐͌̈́̌A̷̱̱̻̻̳̲̳̽̆͆̋͐͗́͂̕A̷̝̰̞̣̅̉̑Ḣ̸̨̟̩̮͍̹̝͚̖̌̇͂̅̂͑́̓̂͘͜͜ͅH̸̛͕̖͎͓̝̩̪͈̐̒̒́̉̈́̊̇̑͝͝ͅH̶̡̧̻̩͙̗̰̯̩̖̱̥͋Ă̶̯̦͖̺̱̙̦̫̞͇͚͆̈́̈͆̃̀̎̕ͅȂ̵̦̰̣̰̙̰͝ͅͅḦ̷̠̩̥͗̍͗͘A̶̱͑̓̊͆͒̅̀͐H̶̸̟̳̜̪͍̦͚͈̹̤̘̗̮̮̰̅͗̈́͛͗̆̑͌̉͆", "speaker": "monster"},

	{"text": "it keeps talking nonsense!", "speaker": "friend"},

	{"text": "y̸̭͇͎̠͈̖̭̞͈͉̐̓͒͌̒͝o̷̡̩̩͎̱̗̬͓̿͊̋̀̏ŭ̸̲͈̔͂̑̑̃̇̃͂͝ͅ ̸̡̛̩̖̌̊̅̍̽̏͝͠r̶̰͊́̈̾͛͑́͂͐͒̆͝ę̸͚͈͈̲̬̂̽̒̀̄̀̔̀́̉͑̕ả̵̡̹͖͈̘̘̬͔̻̟̺͋ļ̴̝͔̭͇̮̦̜̘̫͖̀͛̀̎̎͂̉͛̚͝l̷̛̳̤̠̹̽͆̔͌͐̓́͋͜y̵̫̙̮̼̣̳͉̙̞̗̯̽͛́̌ͅ ̴͖̜͎͚͔̲͎̼̱̍̐̽̅́̉̕͘͝͠w̴̙̲͎̦̫̼̣̗͈͙͒́̌̔̐́͒͗̓ą̶̔̏̀̆̈̔͊̃̿̌̀n̷̛̬͖̼͙̼̖̽̂̍̈́̎̾̒n̶̡͍̪̞̪̞̜̫͚̯͉̜̑̈̌̔́a̷̧̧̢̧̠̝̮͕̪̮͉͔͗͋̈̅̋̅͌̕ ̷̡̛̜͕̩̬̗̄̑̀̈́͛̃̃̽͝d̷͉͎̠̻̝̈́͑̎̔̌̑̕o̵͎̮͓̩̼͚̦̱͖̜̦͂̊̅̑̿̈́̍̚ ̷̢̻̗̳̫͒̒̌͂͋́̾̉̿̎͘̚t̵̨͍̩̜͍͓͒̃͠h̶͓̰́̿í̶̢̢̙̠̰͔̬̞̿̎͐͗̐͝s̷̢͙̪̼̦̞͔̟͇̬͗̾̆ ̶͚̂̿̍͛͐̌́̏̂?̵̨͙͔͇͈̳̹͚̔̌͝", "speaker": "monster"},

	{"text": "...HELP!!", "speaker": "friend"},

	{"text": "e̷̗̺͚̤̋̄̆̕v̵̥̰̺͕͖͙̆͐̽̏͘̚͝ͅè̴̡̩͙͍̤̭̌́̌̚͝͝r̵̼̪̰͎͉̺͔͓̈̾͘y̸̪͎͙͔͊ö̸̩͈̇̇̍̇̍͋̿̈́̕̚̕ņ̸̘̻̤̏̏̇̃͒͒̅̆̓͝ë̴̡̧̻̩͚͍̝̘́̽̒͂̊͌̕͝ ̴̮̺̖͊͜ì̸̧̤͕̪̤͕́̀͛́͐͠s̷̹̖̤̑̀͊̒̀͝ ̵̩̣͕̍̍̐̏́̈́g̴̲̮̖͈̹̠͎̮̥̬̤̀̓̈̑͗̽̃̂͋͑͛̌ȯ̶̲̜̔n̵͈͖̖͇͋̔̾̃̈́n̸͇̗͚̘̠͕̩̤̓̎̀͝͠a̴̡̭̲̠̮̹̝̘̩̅̎̾̑̀͝ ̷̛̝̉̔̒͛̇̓͛̂͊̕̕ḋ̸͇̙̭̲̳̙̿̀͋̿̑͒̒͝i̴̢̨̛͔̖̖̺̫͕͉͖͔̊̐̐͂ͅȩ̷̢̦͓̼̺̫̟̥̈́̅̓̔̾͋̓̌̌͘͠͝.", "speaker": "monster"},

	{"text": "w̶̢̤̺͚͙̬̪͕̩̖̿̀́̓̂̚̕͘̚͝͠͝ḛ̵̛̜͙̞̬̖͉͔̩̂͑̈́̀͝ ̵̧̛̛͚̪̺̗̼͓͇͚̺̦͆̆̓̍̀͊͋͆͝͝ͅŵ̷̟͉̿a̶̺͓̥̠̤̫̜̪͗̎͐͠ń̷̨̰̪̭̘̣͓͇̗̼͙̍̂͂̊̄̍̃ṯ̶̢͇̝͔̻̎̚͘͠.̴̩͙̙̄̑́͋̄̾͘͠.̶̡̛̙̙̽̀̍̋̆̈́.̴̧̢̼͚͔̰̥͙̿̏̎͑̀̅.̵̯̻͚̲̯̦͔̺͖̘̜̑̀̂͝ͅ.̴̢̛̮̬̩̤̭̺͌̇͆.̶̧̧̪̣͍͙̬͉̘̾̈́͊͠.̸̛̗̰̺̟͇̈́̾̈́̓̎̅̏̎̄̍.̷̡̨̧̗͎̯̗̟̞͖̪͈̂̈́͒̂̐.̵͕̱̼͖͓̲̬͍̤̲̆̊̑̏̔́͑͆̕̚͠.̵͍̓̃.̷̗̯̗̂̚.̷̤̖̜̯̜̜̔̔̈̌͛́̆͐͘͠͝͠ͅ.̷̢̝̟̣̊́͒̏.̸͖͉̭́̐̾̆͒͒́̓̌̌̋͠.̵̞̪͕̝͚̫̦͓̯͉̞̤̏͒̾̎̌̀̽̏̈́͘.̵͓̬͍͐̂͆̃̑̈́̋͝.̸̛̫͇̺͔̯̪͎̤͎͆̈́̈̄͊͌͆̅t̶̛̰̍̅̾̀ͅḥ̵̯̾̓̅̿̕ͅę̴̜̲̲̈͊̆ ̴̧̡̛̺̱͓̪̯̦̦͋͂͒̊͑̈́̍͐̏͠ͅͅP̶̀̃̊̈́̇̀̚͜͝r̴̜͐͗̔̈̊̂̃͂̚i̷̡̨̗̫̣̖̪̞̮͗͝n̵̰̘̪͈̓̓́́̈̀͘̚͝ĉ̸͔̗̲̭͑e̴̖͓̼̝̅̆̐͛s̵̙̑͂̉̐̂̌̆̅̕ͅs̴̛̗̻͈͍͉̫̩̱͗̓̌̂̈̚ ̵̖̜̻̯̟̠͙̈́̑̽Ȁ̵̱̐̎̈́̿̈́͛̒̕̕̚͝H̷̨̲̳̘̬̺̞̹̊͆͑͊̊Ā̸̛͚̤͒́̿̾͛̒̓͘͘Ḥ̸̫̩̝̓̀̄̀̔͠͠Ḁ̴̰͔̀̅̀H̶̦̀̈́̌̄̈̓̓̏Ä̸̖̥̭͈̼́̆̔̔͛͝ͅḀ̴͐̆̈́́H̵̨̢̜̜̳͚̭̠̞̼̳͙̐̎͑̈́͂͝͠Ą̶͍̰̖̭̰͛̇̔͜͝͝H̸̹̜̓̂͌͐̈́̆̿͐͘Ḫ̴̿̃͐̋ͅA̷̯̭͚͈͔̝̻̹̅́̆͊͋͝͝Ḩ̵̡̨͚̫͖̼̜̍̔̒͒̎Ǎ̴̲̰̦̟͛̾͛̀̀̀͠A̸̺̺̱̩̙̅̇̿̐H̶̹͝A̵͚̯͕̭̼͚͇͔͋̍̾̌̄̚H̶̜̹̓̄H̵̰̖̜̖̊̏̆͊͌̑̂", "speaker": "monster"},

	{"text": "P̷̢̗͈̲̼̼͙̰̭͗͌̏̎̏̋̽͒̿̋̕͝R̶͖̘͕̿Į̸̨̩̺̱̤͔̙͉̰̅́͘N̵̛͇̞͔̗̲̳̎̓̈̓́̀̆̍̕͠C̵̣̘̘͖͉̑͋Ȩ̸̡͇̺̭͙̬̥̣̗͉̿̒̑̌̓̐̂̑̕̚͘͜S̶̡̛͓̟͎͚̥͌̎͌̈̕̚͜Ş̵̢̧̡̣̲͎̝̱̠̯͊̿͌̽̓͘̚͠͝ ̴̬͉͈̘̂̆̏̅̕P̷̢̟̣͍̞̪͔͓̺̙͚̉̚R̴̡̜̱̝̘͓͍̪̲̻͎͐́͂͑̎̍̓̿̾͂͊͑Ĩ̴̧̠̞̦̰̞̟̊̃̂̔̕͝͠N̶͔̗̜͕̂͋̄̄̓̆̔͘͝Ç̸̙͓̹̘̹̈́̎͝Ḛ̶̞͓̹̪̫̱̗͇͆̿̈́Ş̵̞̘̝͎̪̠̙͍́̈́̃͆̏̉̽̄̐̈̚͘͜ͅS̴̗̹̪̮̣̺̙̭͍̥̲̈́̓̔͛͒́̐̈́͘ͅ ̵̰͓̈̈̅͑́̉P̷̛̮͔͇̔͒͛̌̆̒̋͛̈́͐̑R̴͔̓́̃̈́̈́̈̂Ī̵̯̹̗̻̭̑̓̍́̿̄̑́͂́͘N̸̡͕̤̲̺̥̠̹͂̄͑C̵̘̤̬͚̮̗̺͚͎̀̒̽̄̒͜͠E̶̤͖̣̝̻͉͕̰̜̙͐͗̌̑̂̅̐͑̉͒͝S̷̡̡̛̥͔̝̲̬̣̣̥̾̐̎̃̄̕̕͠S̴͉͍̥̼̔͝ ̸̢̨̬̘̰͈̫̱̄͒̅͋̅̓̋̊̚͘Ą̶̢̼͇̱̳̆̾̃͋̆̎̔̿̓͝͝A̸̛͙̋Ą̶̡̬̤̫̬͓̐̑̒̈͒̆͑̈́̅͝A̸̧͍͙͈͉̞̗̙̳̯̣̬͂A̶̳͂̈́̽̊̾̂̓̌͝͝Ā̸̢̱͍̫̬͈̜̝̹̩̣̍͒̑͋̃À̴̧͇͚̽̆̐Å̴̢̳̭̆͂̀̅́̃̀̕Ȃ̵̡̰̳̼̯̖̬̓̇̅̏͌̈́̃̅ͅH̵̙͛̋͐̏͒͒͐͝ ̸̡͉̙͉̠̲̯̯̠̀̽͝I̷̱̒̇̓̈́̔͂̋͜T̷̹̞̲̳̠͍͔͖̬̹̦̺̾͆͆͒͐̔͐̚ ̶̜̪̪̺̥̟͎̹̝̈́͑̈́́̎̈́̐̌M̵̡̡̛͚̩̪̦̭̦̤̗̓͑̀̇̏͊̄̃͘͠͝A̵̫̳͖̼̍̂K̸̨̲̻̰̺̦̼͙̯̫̋̈́͌͗̀͜Ȅ̵̢̦͕̻̲͓̆̉͆̾̆͝͝͝͝S̸̢͈̯̭͓͇̎͗̈́͗̑͊̀̚ ̶͉̬̯͕̩̦͍̃̒̈̿̌̿̂̕͘͜M̶̢̜̱̫͇̲͕̒́̍͑̄͠͝ͅE̷̼̝̜͉̗̯̰̩̣̾̀͠ͅ ̵͙̠̭͈̔̇̀̔̄͗͌̐̍̕͠C̷̛̬͕̟͔̬̀͘Ŕ̸̳̈́́͑͛̌̈́̾A̵̡̧̱͓̗̠̻̞̝̍̓̇̀̈́̓̓ͅÀ̴̡̬͖̪̆̚A̸͈͉̜̯͎͉͇͇̅͂͂̇̓̀Ȧ̵͈̾͗̐̿͗A̴̲̘̘̿̈́A̴̬̅̆͋̇̓̀͛̃͑̃͊̏Ą̷̛̛͑̄̎̓̽̋̆̈́́Á̷̢̬̖̫͇̜̼̤̘͎͇̄̅͆͆͘A̵̡̦͈̲͎̹̘͎̯̝̜͐̈̽͐̽Ą̶̛̠͖̼̦͇̻̭̞͉͓̐͂̓͊̒̎͒̑̿͝ͅǍ̵̢̬̳̼͕̦̰̝̳͈̦̠́͗͊Á̷̳͉͍̳͍͇̖́̃͗͜͠Ả̶̯̙̟̝͑̌̆̊̇͗͛̑̓Z̵͇̦͚̯̠̙̈́͌͠Y̶͎̖̔̌̈́", "speaker": "monster"}
]
var normal_dialogue: Array[Dictionary] = [
	
	{"text": "I-I can't believe it ! you really beat it!", "speaker": "friend"},
{"text": "aaargh...", "speaker": "tim"},
{"text": "tim ! you're alive ??", "speaker": "friend"},
{"text": "...aaaaaaaaargh...it hurts.....", "speaker": "tim"},
{"text": "of course I'm alive", "speaker": "tim"},
{"text": "you ! you were amazing ! I saw everything", "speaker": "friend"},
{"text": "I really can't believe it...", "speaker": "friend"},
{"text": "hey you...have you seen my father and my sister???", "speaker": "tim"},
{"text": "they must be so worried", "speaker": "tim"},
{"text": "and I need my sister's medicine skills", "speaker": "tim"},
{"text": "...really ?? you know where they are ?", "speaker": "tim"},
{"text": "could you lead us to them ?", "speaker": "tim"}
]
func _ready():
	interaction_prompt.visible = false

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	music_zone.body_entered.connect(_on_music_zone_entered)
	music_zone.body_exited.connect(_on_music_zone_exited)
	if GameState.is_monster_defeated("monster_1"):
		$Monster1.hide()
		$Monster1.process_mode = Node.PROCESS_MODE_DISABLED

	update_dialogue_bubble()


func _on_body_entered(body):
	if body is Player:
		player = body
		player_nearby = true
		interaction_prompt.visible = true
		update_dialogue_bubble()


func _on_body_exited(body):
	if body is Player:
		if player == body:
			player = null

		player_nearby = false
		interaction_prompt.visible = false


func _process(_delta):
	if player_nearby \
	and Input.is_action_just_pressed("interact") \
	and not dialogue_box.dialogue_active:
		start_dialogue()


func start_dialogue():
	current_dialogue_id = get_current_dialogue_id()

	var dialogue := get_current_dialogue()
	var prepared_dialogue := prepare_dialogue(dialogue)

	interaction_prompt.visible = false

	GameState.mark_dialogue_seen(current_dialogue_id)
	update_dialogue_bubble()

	dialogue_box.start_dialogue(prepared_dialogue)


func get_current_dialogue_id() -> String:
	if GameState.is_monster_defeated("monster_1"):
		if not GameState.has_seen_dialogue(npc_id + "_after_battle"):
			return npc_id + "_after_battle"

		return npc_id + "_normal"

	if not GameState.has_seen_dialogue(npc_id + "_first_meeting"):
		return npc_id + "_first_meeting"

	return npc_id + "_normal"


func get_current_dialogue() -> Array[Dictionary]:
	var dialogue_id := get_current_dialogue_id()

	if dialogue_id == npc_id + "_first_meeting":
		return first_dialogue

	return normal_dialogue


func _on_dialogue_finished():
	if current_dialogue_id == npc_id + "_first_meeting":

		GameState.save_return_position(player.global_position)

		print("POSITION SAUVEGARDEE : ", player.global_position)

		current_dialogue_id = ""

		SceneTransition.change_scene("res://scenes/battle.tscn")
		return

	if current_dialogue_id == npc_id + "_after_battle":
		GameState.tim_needs_escort = true

	current_dialogue_id = ""

func update_dialogue_bubble():
	var dialogue_id := get_current_dialogue_id()

	new_dialogue_bubble.visible = (
		not GameState.has_seen_dialogue(dialogue_id)
		and (
			dialogue_id == npc_id + "_first_meeting"
			or dialogue_id == npc_id + "_after_battle"
		)
	)

	new_dialogue_bubble.visible = (
		not GameState.has_seen_dialogue(dialogue_id)
		and (
			dialogue_id == npc_id + "_first_meeting"
			or dialogue_id == npc_id + "_after_battle"
		)
	)

	new_dialogue_bubble.visible = (
		dialogue_id == npc_id + "_first_meeting"
	)


func prepare_dialogue(dialogue: Array[Dictionary]) -> Array[Dictionary]:
	var prepared: Array[Dictionary] = []

	for message in dialogue:
		var new_message := message.duplicate()
		var speaker: String = message.get("speaker", "")

		if speaker == "tim":
			new_message["portrait"] = tim_portrait

		elif speaker == "friend":
			new_message["portrait"] = friend_portrait

		elif speaker == "monster":
			new_message["portrait"] = monster_portrait

		else:
			new_message["portrait"] = null

		prepared.append(new_message)

	return prepared
func _on_music_zone_entered(body):
	if body is Player:
		if not GameState.is_monster_defeated("monster_1"):
			fade_music(normal_music, monster_music)


func _on_music_zone_exited(body):
	if body is Player:
		if not GameState.is_monster_defeated("monster_1"):
			fade_music(monster_music, normal_music)	
func fade_music(
	from_music: AudioStreamPlayer,
	to_music: AudioStreamPlayer
):
	var tween := create_tween()

	to_music.volume_db = -40.0
	to_music.play()

	tween.set_parallel(true)

	tween.tween_property(
		from_music,
		"volume_db",
		-40.0,
		1.5
	)

	tween.tween_property(
		to_music,
		"volume_db",
		0.0,
		1.5
	)

	await tween.finished

	from_music.stop()
	from_music.volume_db = 0.0
