extends Node

static var cardData : Dictionary = {}

static var card_assets : Dictionary

static func slog(msg: String)->void:
	print_rich("[[b][color=PURPLE]GLOBAL[/color][/b]]: "+msg)

# static func loadAllCardsJSON(recursive:bool=true):
# 	var cards_dir_list = ["res://data/cards/"]
# 	for elem in cards_dir_list:
# 		var dir = DirAccess.open(elem)
# 		if dir:
# 			dir.list_dir_begin()
# 			var file_name = dir.get_next()
# 			while file_name != "":
# 				var file_path = dir.get_current_dir()+"/"+file_name
# 				if !dir.current_is_dir():
# 					var jsonFile = FileAccess.open(file_path,FileAccess.READ)
# 					print(jsonFile.get_as_text())
# 					var json_parsed:Dictionary = JSON.parse_string(jsonFile.get_as_text())
# 					var card_name:String = file_name.replace(".json","")
# 					cardData[card_name] = json_parsed
# 					print_rich("loaded card [b]"+card_name+"[/b] : [color=YELLOW]"+file_path)
# 				elif recursive :
# 					cards_dir_list.append(file_path)
# 				file_name = dir.get_next()
# 		else:
# 			print("An error occurred when trying to access the path.")

static func loadAllCards(recursive:bool=false):
	slog("Started loading card files...")
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
					slog("loaded card [b]"+ressource.card_name+"[/b] : [color=YELLOW]"+file_path+"[/color]")
				elif recursive:
					cards_dir_list.append(file_path)
				file_name = dir.get_next()
		else:
			print("An error occurred when trying to access the path.")

func get_card(card_name:String):
	return cardData[card_name]


static func initialise_directory():
	if !DirAccess.dir_exists_absolute("user://decks/"):
		slog("'decks' directory does not exists!")
		slog("Creating 'decks' directory...")
		DirAccess.make_dir_absolute("user://decks/")
	
static func preload_assets():
	var folders = ["frames","bg","cost"]
	slog("Loading cards assets")
	for folder in folders:
		slog("loading '"+folder+"'...")
		card_assets[folder] = {}
		for file in DirAccess.get_files_at("res://assets/"+folder):
			if file.get_extension() != "import":
				var index = file.get_file().get_slice(".",0)
				slog("loading '"+file+"' to index "+folder+"/"+index)
				card_assets[folder][index] = load("res://assets/"+folder+"/"+file)	

func _init():
	initialise_directory()
	preload_assets()
	loadAllCards(true)
