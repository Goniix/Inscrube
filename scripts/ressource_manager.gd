class_name RessourceManager
extends Node


static var cardData : Dictionary = {}

static func loadAllCards(recursive:bool=false):
	cardData = {}
	var cards_dir_list = ["res://data/cards/"]
	for elem in cards_dir_list:
		var dir = DirAccess.open(elem)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				var file_path = dir.get_current_dir()+"/"+file_name
				if !dir.current_is_dir():
					if '.tres.remap' in file_path:
						file_path = file_path.trim_suffix('.remap')
					var ressource: CardData = load(file_path)
					cardData[ressource.card_name] = ressource
					print_rich("loaded card [b]"+ressource.card_name+"[/b] : [color=YELLOW]"+file_path)
				elif recursive:
					cards_dir_list.append(file_path)
				file_name = dir.get_next()
		else:
			print("An error occurred when trying to access the path.")



static func get_card(card_name:String):
	return cardData[card_name]