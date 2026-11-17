extends Control

signal opened
signal closed

@onready var inventory: Inventory = preload("res://inventory/playerinventory.tres")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()
var isOpen: bool = false

func _ready():
	update()

func update():
	for i in range(min(inventory.items.size(),slots.size())):
		slots[i].update(inventory.items[i])

func open():
	visible = true
	isOpen = true
	get_parent().get_node("TextureButton_Menu").visible = false
	opened.emit()
	
func close():
	visible = false
	isOpen = false 
	get_parent().get_node("TextureButton_Menu").visible = true
	closed.emit()
	
