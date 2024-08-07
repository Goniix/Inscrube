class_name Hand
extends Node2D

var allow_pick : bool = true
var attached_cards: Array[Card] = []

func get_game_root():
	return get_tree().root.get_child(0)

func get_card_index(card: Card):
	var i = 0
	for elem in attached_cards:
		if elem == card:
			return i
		i+= 1
	return -1

func add_card(card: Card, pos: int):
	#attached_cards.append(card)
	assert(pos>=0)
	attached_cards.insert(pos,card)

func remove_card(card: Card):
	attached_cards.erase(card)

func refresh_cards_color():
	var game_root = get_game_root()
	var total_value = game_root.get_total_value()
	for card in attached_cards:
		card.color_tween = create_tween()
		var fct = (1 if (not game_root.card_in_play and card.card_cost["blood"]<=total_value) else 0.5)
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
		card_elem.set_z_index(i)
		i+=1

func get_card_position(card: Card):
	var card_index: int = get_card_index(card)
	$HandPath/PathFollow2D.progress_ratio = ((card_index+1) as float)/(len(attached_cards)+1)
	return [$HandPath/PathFollow2D.global_position,$HandPath/PathFollow2D.rotation]
