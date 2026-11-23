extends Control

@onready var health_potion = $HealthPotion
@onready var potion_quantity = $PotionQuantity

func _ready() -> void:
	var quantity = GameState.get_item_count("health_potion")

	health_potion.visible = quantity > 0
	potion_quantity.text = str(quantity)


func _on_texture_button_pressed() -> void:
	SceneTransition.change_scene("res://maingame.tscn")
