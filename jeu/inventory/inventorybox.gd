
extends Control

signal opened
signal closed

@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

var isOpen: bool = false

var health_potion_item: InventoryItem = preload("res://inventory/items/healthpotion.tres")
var jam_item: InventoryItem = preload("res://inventory/items/jam.tres")

func _ready():
	update()


func update():
	for slot in slots:
		slot.update(null)
	var slot_index=0
	for item_id in GameState.inventory_order:
		if GameState.has_item(item_id):
			if slot_index>=slots.size():
				break
			if item_id=="health_potion":
				slots[slot_index].update(health_potion_item)
				slot_index+=1
			elif item_id=="cherry_jam":
				slots[slot_index].update(jam_item)
				slot_index+=1

func open():
	visible = true
	isOpen = true
	update()
	get_parent().get_node("TextureButton_Menu").visible = false
	opened.emit()


func close():
	visible = false
	isOpen = false
	get_parent().get_node("TextureButton_Menu").visible = true
	closed.emit()
