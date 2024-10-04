class_name DeckData
extends Node

var deck_name: String
var card_list: Array[CardData] = []


func _init(_name:String= ""):
	self.deck_name = _name

func _to_string():
	return "Deck("+deck_name+")"

func toJSON()-> Dictionary:
	var card_list_copy: Array = []
	card_list_copy.append(card_list)
	var res_dict = {
		"deck_name" = deck_name,
		"card_list" = card_list
	}
	return res_dict

static func fromJSON(json_data:Dictionary)->DeckData:
	var res: DeckData = DeckData.new(json_data["deck_name"])
	for card in json_data["card_list"]:
		res.card_list.append(card)

	return res


