extends Area2D

@export var npc_id: String = "children"

var player_nearby := false
var current_dialogue_id: String = ""

@onready var interaction_prompt = $InteractionPrompt
@onready var new_dialogue_bubble = $DialogueBubble
@onready var dialogue_box: DialogueBox = $"../CanvasLayer/BoiteDialogues"

@export var tim_portrait: Texture2D
@export var friend_portrait: Texture2D
@export var monster_portrait: Texture2D


var first_dialogue: Array[Dictionary] = [
	{"text": "ray... are you okay???", "speaker": "tim"},
	{"text": "...", "speaker": "friend"},
	{"text": "i knew I shouldn't have gone so far...", "speaker": "tim"},
	{"text": "my father warned me.", "speaker": "tim"},
	{"text": "I'm so sorry I couldn't save you, Ray...", "speaker": "tim"},
	{"text": "...", "speaker": "tim"},

	{"text": "are you... here to save me?", "speaker": "tim"},
	{"text": "no... this thing is too strong for us.", "speaker": "tim"},
	{"text": "it's gonna kill my family...", "speaker": "tim"},
	{"text": "and then the whole village...", "speaker": "tim"},
	{"text": "and we're next.", "speaker": "tim"},

	{"text": "y-you're not saying anything...", "speaker": "tim"},
	{"text": "I-I suppose you're too scared as well.", "speaker": "tim"},
	{"text": "no...", "speaker": "tim"},
	{"text": "you really want to fight it?", "speaker": "tim"},
	{"text": "you better be qui--", "speaker": "tim"},

	{"text": "Ḧ̸̡́̀̐̽̈͘Ą̶̛̜̦̩̹̩̫̖̤̤͎̂̐H̴̤̉̄̊̈́̍̍̕̚A̷̝̋̐̆͌̾͋̕͠͠A̴̹̟͕͕̟̦͗̅H̴̪̘̜̮̤̥͚̠͉̜͈̋̂̀̓͋̈̿̐̂̚͠Ȃ̶̧̡̻̟̻̰̹̖̳̻̱͕̎̊͋̍̓̾̿̈́̕͝Ḩ̷̙͔̒A̷͚̣͙̪̼̫̜̙͊̏́͛̄͂͗̏̌̐̃͜͝A̵̛̪͓̮̟̝̼̠̒́͊̽̄̇̆̈́A̷̛̛̻͙̼̺̐̌͗͌̏̃̀͂Á̴̘̱̹͚̿̀̓͗̈̾̈́̇̕͝͝ͅȦ̵͓͙͓̺͍͇̌̋̓̊̋̀͘̕A̵͔͔͈͉͌̐͌̈́̌A̷̱̱̻̻̳̲̳̽̆͆̋͐͗́͂̕A̷̝̰̞̣̅̉̑Ḣ̸̨̟̩̮͍̹̝͚̖̌̇͂̅̂͑́̓̂͘͜͜ͅH̸̛͕̖͎͓̝̩̪͈̐̒̒́̉̈́̊̇̑͝͝ͅH̶̡̧̻̩͙̗̰̯̩̖̱̥͋Ă̶̯̦͖̺̱̙̦̫̞͇͚͆̈́̈͆̃̀̎̕ͅȂ̵̦̰̣̰̙̰͝ͅͅḦ̷̠̩̥͗̍͗͘A̶̱͑̓̊͆͒̅̀͐H̶̸̟̳̜̪͍̦͚͈̹̤̘̗̮̮̰̅͗̈́͛͗̆̑͌̉͆", "speaker": "monster"},

	{"text": "it keeps talking nonsense!", "speaker": "tim"},

	{"text": "y̸̭͇͎̠͈̖̭̞͈͉̐̓͒͌̒͝o̷̡̩̩͎̱̗̬͓̿͊̋̀̏ŭ̸̲͈̔͂̑̑̃̇̃͂͝ͅ ̸̡̛̩̖̌̊̅̍̽̏͝͠r̶̰͊́̈̾͛͑́͂͐͒̆͝ę̸͚͈͈̲̬̂̽̒̀̄̀̔̀́̉͑̕ả̵̡̹͖͈̘̘̬͔̻̟̺͋ļ̴̝͔̭͇̮̦̜̘̫͖̀͛̀̎̎͂̉͛̚͝l̷̛̳̤̠̹̽͆̔͌͐̓́͋͜y̵̫̙̮̼̣̳͉̙̞̗̯̽͛́̌ͅ ̴͖̜͎͚͔̲͎̼̱̍̐̽̅́̉̕͘͝͠w̴̙̲͎̦̫̼̣̗͈͙͒́̌̔̐́͒͗̓ą̶̔̏̀̆̈̔͊̃̿̌̀n̷̛̬͖̼͙̼̖̽̂̍̈́̎̾̒n̶̡͍̪̞̪̞̜̫͚̯͉̜̑̈̌̔́a̷̧̧̢̧̠̝̮͕̪̮͉͔͗͋̈̅̋̅͌̕ ̷̡̛̜͕̩̬̗̄̑̀̈́͛̃̃̽͝d̷͉͎̠̻̝̈́͑̎̔̌̑̕o̵͎̮͓̩̼͚̦̱͖̜̦͂̊̅̑̿̈́̍̚ ̷̢̻̗̳̫͒̒̌͂͋́̾̉̿̎͘̚t̵̨͍̩̜͍͓͒̃͠h̶͓̰́̿í̶̢̢̙̠̰͔̬̞̿̎͐͗̐͝s̷̢͙̪̼̦̞͔̟͇̬͗̾̆ ̶͚̂̿̍͛͐̌́̏̂?̵̨͙͔͇͈̳̹͚̔̌͝", "speaker": "monster"},

	{"text": "...HELP!!", "speaker": "tim"},

	{"text": "e̷̗̺͚̤̋̄̆̕v̵̥̰̺͕͖͙̆͐̽̏͘̚͝ͅè̴̡̩͙͍̤̭̌́̌̚͝͝r̵̼̪̰͎͉̺͔͓̈̾͘y̸̪͎͙͔͊ö̸̩͈̇̇̍̇̍͋̿̈́̕̚̕ņ̸̘̻̤̏̏̇̃͒͒̅̆̓͝ë̴̡̧̻̩͚͍̝̘́̽̒͂̊͌̕͝ ̴̮̺̖͊͜ì̸̧̤͕̪̤͕́̀͛́͐͠s̷̹̖̤̑̀͊̒̀͝ ̵̩̣͕̍̍̐̏́̈́g̴̲̮̖͈̹̠͎̮̥̬̤̀̓̈̑͗̽̃̂͋͑͛̌ȯ̶̲̜̔n̵͈͖̖͇͋̔̾̃̈́n̸͇̗͚̘̠͕̩̤̓̎̀͝͠a̴̡̭̲̠̮̹̝̘̩̅̎̾̑̀͝ ̷̛̝̉̔̒͛̇̓͛̂͊̕̕ḋ̸͇̙̭̲̳̙̿̀͋̿̑͒̒͝i̴̢̨̛͔̖̖̺̫͕͉͖͔̊̐̐͂ͅȩ̷̢̦͓̼̺̫̟̥̈́̅̓̔̾͋̓̌̌͘͠͝.", "speaker": "monster"},

	{"text": "w̶̢̤̺͚͙̬̪͕̩̖̿̀́̓̂̚̕͘̚͝͠͝ḛ̵̛̜͙̞̬̖͉͔̩̂͑̈́̀͝ ̵̧̛̛͚̪̺̗̼͓͇͚̺̦͆̆̓̍̀͊͋͆͝͝ͅŵ̷̟͉̿a̶̺͓̥̠̤̫̜̪͗̎͐͠ń̷̨̰̪̭̘̣͓͇̗̼͙̍̂͂̊̄̍̃ṯ̶̢͇̝͔̻̎̚͘͠.̴̩͙̙̄̑́͋̄̾͘͠.̶̡̛̙̙̽̀̍̋̆̈́.̴̧̢̼͚͔̰̥͙̿̏̎͑̀̅.̵̯̻͚̲̯̦͔̺͖̘̜̑̀̂͝ͅ.̴̢̛̮̬̩̤̭̺͌̇͆.̶̧̧̪̣͍͙̬͉̘̾̈́͊͠.̸̛̗̰̺̟͇̈́̾̈́̓̎̅̏̎̄̍.̷̡̨̧̗͎̯̗̟̞͖̪͈̂̈́͒̂̐.̵͕̱̼͖͓̲̬͍̤̲̆̊̑̏̔́͑͆̕̚͠.̵͍̓̃.̷̗̯̗̂̚.̷̤̖̜̯̜̜̔̔̈̌͛́̆͐͘͠͝͠ͅ.̷̢̝̟̣̊́͒̏.̸͖͉̭́̐̾̆͒͒́̓̌̌̋͠.̵̞̪͕̝͚̫̦͓̯͉̞̤̏͒̾̎̌̀̽̏̈́͘.̵͓̬͍͐̂͆̃̑̈́̋͝.̸̛̫͇̺͔̯̪͎̤͎͆̈́̈̄͊͌͆̅t̶̛̰̍̅̾̀ͅḥ̵̯̾̓̅̿̕ͅę̴̜̲̲̈͊̆ ̴̧̡̛̺̱͓̪̯̦̦͋͂͒̊͑̈́̍͐̏͠ͅͅP̶̀̃̊̈́̇̀̚͜͝r̴̜͐͗̔̈̊̂̃͂̚i̷̡̨̗̫̣̖̪̞̮͗͝n̵̰̘̪͈̓̓́́̈̀͘̚͝ĉ̸͔̗̲̭͑e̴̖͓̼̝̅̆̐͛s̵̙̑͂̉̐̂̌̆̅̕ͅs̴̛̗̻͈͍͉̫̩̱͗̓̌̂̈̚ ̵̖̜̻̯̟̠͙̈́̑̽Ȁ̵̱̐̎̈́̿̈́͛̒̕̕̚͝H̷̨̲̳̘̬̺̞̹̊͆͑͊̊Ā̸̛͚̤͒́̿̾͛̒̓͘͘Ḥ̸̫̩̝̓̀̄̀̔͠͠Ḁ̴̰͔̀̅̀H̶̦̀̈́̌̄̈̓̓̏Ä̸̖̥̭͈̼́̆̔̔͛͝ͅḀ̴͐̆̈́́H̵̨̢̜̜̳͚̭̠̞̼̳͙̐̎͑̈́͂͝͠Ą̶͍̰̖̭̰͛̇̔͜͝͝H̸̹̜̓̂͌͐̈́̆̿͐͘Ḫ̴̿̃͐̋ͅA̷̯̭͚͈͔̝̻̹̅́̆͊͋͝͝Ḩ̵̡̨͚̫͖̼̜̍̔̒͒̎Ǎ̴̲̰̦̟͛̾͛̀̀̀͠A̸̺̺̱̩̙̅̇̿̐H̶̹͝A̵͚̯͕̭̼͚͇͔͋̍̾̌̄̚H̶̜̹̓̄H̵̰̖̜̖̊̏̆͊͌̑̂", "speaker": "monster"},

	{"text": "P̷̢̗͈̲̼̼͙̰̭͗͌̏̎̏̋̽͒̿̋̕͝R̶͖̘͕̿Į̸̨̩̺̱̤͔̙͉̰̅́͘N̵̛͇̞͔̗̲̳̎̓̈̓́̀̆̍̕͠C̵̣̘̘͖͉̑͋Ȩ̸̡͇̺̭͙̬̥̣̗͉̿̒̑̌̓̐̂̑̕̚͘͜S̶̡̛͓̟͎͚̥͌̎͌̈̕̚͜Ş̵̢̧̡̣̲͎̝̱̠̯͊̿͌̽̓͘̚͠͝ ̴̬͉͈̘̂̆̏̅̕P̷̢̟̣͍̞̪͔͓̺̙͚̉̚R̴̡̜̱̝̘͓͍̪̲̻͎͐́͂͑̎̍̓̿̾͂͊͑Ĩ̴̧̠̞̦̰̞̟̊̃̂̔̕͝͠N̶͔̗̜͕̂͋̄̄̓̆̔͘͝Ç̸̙͓̹̘̹̈́̎͝Ḛ̶̞͓̹̪̫̱̗͇͆̿̈́Ş̵̞̘̝͎̪̠̙͍́̈́̃͆̏̉̽̄̐̈̚͘͜ͅS̴̗̹̪̮̣̺̙̭͍̥̲̈́̓̔͛͒́̐̈́͘ͅ ̵̰͓̈̈̅͑́̉P̷̛̮͔͇̔͒͛̌̆̒̋͛̈́͐̑R̴͔̓́̃̈́̈́̈̂Ī̵̯̹̗̻̭̑̓̍́̿̄̑́͂́͘N̸̡͕̤̲̺̥̠̹͂̄͑C̵̘̤̬͚̮̗̺͚͎̀̒̽̄̒͜͠E̶̤͖̣̝̻͉͕̰̜̙͐͗̌̑̂̅̐͑̉͒͝S̷̡̡̛̥͔̝̲̬̣̣̥̾̐̎̃̄̕̕͠S̴͉͍̥̼̔͝ ̸̢̨̬̘̰͈̫̱̄͒̅͋̅̓̋̊̚͘Ą̶̢̼͇̱̳̆̾̃͋̆̎̔̿̓͝͝A̸̛͙̋Ą̶̡̬̤̫̬͓̐̑̒̈͒̆͑̈́̅͝A̸̧͍͙͈͉̞̗̙̳̯̣̬͂A̶̳͂̈́̽̊̾̂̓̌͝͝Ā̸̢̱͍̫̬͈̜̝̹̩̣̍͒̑͋̃À̴̧͇͚̽̆̐Å̴̢̳̭̆͂̀̅́̃̀̕Ȃ̵̡̰̳̼̯̖̬̓̇̅̏͌̈́̃̅ͅH̵̙͛̋͐̏͒͒͐͝ ̸̡͉̙͉̠̲̯̯̠̀̽͝I̷̱̒̇̓̈́̔͂̋͜T̷̹̞̲̳̠͍͔͖̬̹̦̺̾͆͆͒͐̔͐̚ ̶̜̪̪̺̥̟͎̹̝̈́͑̈́́̎̈́̐̌M̵̡̡̛͚̩̪̦̭̦̤̗̓͑̀̇̏͊̄̃͘͠͝A̵̫̳͖̼̍̂K̸̨̲̻̰̺̦̼͙̯̫̋̈́͌͗̀͜Ȅ̵̢̦͕̻̲͓̆̉͆̾̆͝͝͝͝S̸̢͈̯̭͓͇̎͗̈́͗̑͊̀̚ ̶͉̬̯͕̩̦͍̃̒̈̿̌̿̂̕͘͜M̶̢̜̱̫͇̲͕̒́̍͑̄͠͝ͅE̷̼̝̜͉̗̯̰̩̣̾̀͠ͅ ̵͙̠̭͈̔̇̀̔̄͗͌̐̍̕͠C̷̛̬͕̟͔̬̀͘Ŕ̸̳̈́́͑͛̌̈́̾A̵̡̧̱͓̗̠̻̞̝̍̓̇̀̈́̓̓ͅÀ̴̡̬͖̪̆̚A̸͈͉̜̯͎͉͇͇̅͂͂̇̓̀Ȧ̵͈̾͗̐̿͗A̴̲̘̘̿̈́A̴̬̅̆͋̇̓̀͛̃͑̃͊̏Ą̷̛̛͑̄̎̓̽̋̆̈́́Á̷̢̬̖̫͇̜̼̤̘͎͇̄̅͆͆͘A̵̡̦͈̲͎̹̘͎̯̝̜͐̈̽͐̽Ą̶̛̠͖̼̦͇̻̭̞͉͓̐͂̓͊̒̎͒̑̿͝ͅǍ̵̢̬̳̼͕̦̰̝̳͈̦̠́͗͊Á̷̳͉͍̳͍͇̖́̃͗͜͠Ả̶̯̙̟̝͑̌̆̊̇͗͛̑̓Z̵͇̦͚̯̠̙̈́͌͠Y̶͎̖̔̌̈́", "speaker": "monster"}
]
var normal_dialogue: Array[Dictionary] = [
	{"text": "Please... do something!", "speaker": "friend"},
	{"text": "That thing won't let us leave.", "speaker": "tim"}
]


func _ready():
	interaction_prompt.visible = false

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)

	update_dialogue_bubble()


func _on_body_entered(body):
	if body is Player:
		player_nearby = true
		interaction_prompt.visible = true
		update_dialogue_bubble()


func _on_body_exited(body):
	if body is Player:
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
		# Plus tard :
		# start_monster_fight()
		pass

	current_dialogue_id = ""


func update_dialogue_bubble():
	var dialogue_id := get_current_dialogue_id()

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
