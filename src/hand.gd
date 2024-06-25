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

func remove_card(card: Card):
	attached_cards.erase(card)

func refresh_cards_color():
	for card in attached_cards:
		card.color_tween = create_tween()
		var fct = (1 if (Game.allow_card_drag or card.card_cost.get("blood") <= Game.sacrificed_value) else 0.5)
		card.color_tween.tween_property(card,"modulate",Color(fct,fct,fct,1),0.1)

func refresh_cards_pos():
	#print(str(len(attached_cards))+" cartes dans la main")
	var i = 0
	for card_elem in attached_cards:
		if(card_elem.rotation_tween!=null and card_elem.rotation_tween.is_running()):
			card_elem.rotation_tween.kill()
		
		var tween = create_tween()
		var path_data = get_card_position(card_elem)
		tween.tween_property(card_elem,"position", path_data[0], 0.1).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(card_elem,"rotation", path_data[1], 0.1).set_ease(Tween.EASE_OUT)
		card_elem.set_z_index(4+i)
		i+=1

func get_card_position(card: Card):
	var card_index: int = get_card_index(card)
	$HandPath/PathFollow2D.progress_ratio = ((card_index+1) as float)/(len(attached_cards)+1)
	return [$HandPath/PathFollow2D.global_position,$HandPath/PathFollow2D.rotation]
