
extends Control

signal opened
signal closed

@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

var isOpen: bool = false

var health_potion_item: InventoryItem = preload("res://inventory/items/healthpotion.tres")


func _ready():
	update()


func update():
	var quantity = GameState.get_item_count("health_potion")
	if quantity > 0:
		slots[0].update(health_potion_item)
	else:
		slots[0].update(null)
	for i in range(1, slots.size()):
		slots[i].update(null)

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
