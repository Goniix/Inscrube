class_name Game
extends Node

var cardScene : PackedScene = load("res://scenes/card.tscn")

func _init():
	var new_card = cardScene.instantiate()
	new_card.position = Vector2(0,200)
	new_card.get_node("Background").texture = load("res://spr/frames/frame_common_beast.png")
	add_child(new_card)
	
func _process(delta):
	pass
