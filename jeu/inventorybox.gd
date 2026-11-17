extends Control

signal opened
signal closed


var isOpen: bool = false

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
	
