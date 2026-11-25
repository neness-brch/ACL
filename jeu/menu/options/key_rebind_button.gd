class_name KeyRebindButton 

extends Control

@onready var label: Label = $HBoxContainer/Label
@onready var button: Button = $HBoxContainer/Button

@export var action_name : String = "move_up"

func _ready():
	set_process_unhandled_key_input(false)
	set_action_name()
	set_text_for_key()
	
func set_action_name() ->void:
	label.text = "Unassigned"
	
	match action_name:
		"move_up":
			label.text = "Move Up"
		"move_down":
			label.text = "Move Down"
			
		"move_left":
			label.text = "Move Left"
			
		"move_right":
			label.text = "Move Right"
		
		"interact":
			label.text = "Interact"
		"next_dialogue":
			label.text="Next Dialogue"
		"toggle_inventory":
			label.text="Toggle Inventory"
			
func set_text_for_key()->void:
	var action_events=InputMap.action_get_events(action_name)
	var action_event=action_events[0]
	var action_keycode = OS.get_keycode_string(action_event.physical_keycode)
	
	button.text="%s" % action_keycode
	


func _on_button_toggled(toggled_on: bool) -> void:
	if toggled_on :
		button.text="Press any key"
		set_process_unhandled_key_input(true)
		for i in get_tree().get_nodes_in_group("key_button"):
			if i.action_name!= self.action_name:
				i.button.toggle_mode = false
				i.set_process_unhandled_key_input(false)
			
	else: 
		
		for i in get_tree().get_nodes_in_group("key_button"):
			if i.action_name!= self.action_name:
				i.button.toggle_mode = true
				i.set_process_unhandled_key_input(false)
		set_text_for_key()
	
func _unhandled_key_input(event):
	rebind_action_key(event)
	button.button_pressed = false

func rebind_action_key(event)->void:
	InputMap.action_erase_events(action_name)
	InputMap.action_add_event(action_name,event)
	
	set_process_unhandled_key_input(false)
	set_text_for_key()
	set_action_name()
