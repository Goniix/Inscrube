class_name Hand
extends Node2D

var allow_pick : bool = true
var attached_cards: Array[Card] = []

func get_card_index(card: Card):
	var i = 0
	for elem in attached_cards:
		if elem == card:
			return i
		i+= 1
	return -1

func add_card(card: Card):
	attached_cards.append(card)
	refresh_cards_pos()

func refresh_cards_pos():
	for card_elem in attached_cards:
		var tween = create_tween()
		var path_data = get_card_position(card_elem)
		tween.tween_property(card_elem,"position", path_data[0], 0.1).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(card_elem,"rotation", path_data[1], 0.1).set_ease(Tween.EASE_OUT)

func get_card_position(card: Card):
	var card_index: int = get_card_index(card)
	print(card)
	print(card_index)
	$HandPath/PathFollow2D.progress_ratio = ((card_index+1)*1.0)/(1.0*len(attached_cards)+1.0)
	return [$HandPath/PathFollow2D.global_position,$HandPath/PathFollow2D.rotation]
