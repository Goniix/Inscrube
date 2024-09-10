class_name Hand
extends Control

var allow_pick : bool = true
var attached_cards: Array[Card] = []
var hovered: bool = false

func get_game_root():
	return get_tree().root.get_child(0)

func add_card(card: Card, pos: int):
	#attached_cards.append(card)
	assert(pos>=0)
	attached_cards.insert(pos,card)

func remove_card(card: Card):
	attached_cards.erase(card)

func refresh_cards_order():
	for i in range(attached_cards.size()):
		var elem: Card = attached_cards[i]
		elem.move_to_front()

func refresh_cards_color():
	var game_root : Game = get_game_root()
	var total_value = game_root.get_total_value()
	for card in attached_cards:
		card.color_tween = create_tween()
		var fct = (1.0 if (not game_root.card_is_played() and card.get_card_cost(CardData.COST_ENUM.BLOOD)<=total_value) else 0.5)
		card.color_tween.tween_property(card.get_node("SubViewportContainer/SubViewport/SubCard"),"modulate",Color(fct,fct,fct,1),0.1)

func refresh_cards_pos():
	#print(str(len(attached_cards))+" cartes dans la main")
	var i = 0
	for card_elem in attached_cards:
		if(card_elem.rotation_tween and card_elem.rotation_tween.is_running()):
			card_elem.rotation_tween.kill()
		
		card_elem.position_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SPRING)
		var path_data = get_card_position(card_elem)
		var path_position: Vector2 = path_data[0]# + (Vector2(0,-250) if hovered else Vector2.ZERO)
		card_elem.position_tween.tween_property(card_elem,"position", path_position, 0.4)
		card_elem.position_tween.parallel().tween_property(card_elem,"rotation", path_data[1], 0.4)

func get_card_position(card: Card):
	var card_index: int = attached_cards.find(card)
	$HandPath/PathFollow2D.progress_ratio = ((card_index+1) as float)/(len(attached_cards)+1)
	return [$HandPath/PathFollow2D.global_position-card.pivot_offset,$HandPath/PathFollow2D.rotation]
