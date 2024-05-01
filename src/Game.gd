class_name Game
extends Node

static var cardScene : PackedScene = load("res://scenes/card.tscn")
static var cardData : Dictionary = {}
static var artData: Dictionary = {
	"adder":"res://spr/art/Adder.png"
}
static var language = 0


func loadAllCards(recursive:bool=true):
	var cardsDirs = ["res://cards/card_data/"]
	for elem in cardsDirs:
		var dir = DirAccess.open(elem)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				var file_path = dir.get_current_dir()+"/"+file_name
				if !dir.current_is_dir():
					var jsonFile = FileAccess.open(file_path,FileAccess.READ)
					var json_parsed:Dictionary = JSON.parse_string(jsonFile.get_as_text())
					var card_name:String = file_name.replace(".json","")
					cardData[card_name] = json_parsed
					print("loaded card \""+card_name+"\" : "+file_path)
				elif recursive :
					cardsDirs.append(file_path+"/")
				file_name = dir.get_next()
		else:
			print("An error occurred when trying to access the path.")

func dir_contents(path):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			else:
				print("Found file: " + file_name.replace(".json",""))
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")


var new_card
func _init():
	loadAllCards(true)
	
	new_card = cardScene.instantiate()
	new_card.position = Vector2(0,200)
	new_card.load_data(cardData["adder"],"adder")
	new_card.scale = Vector2(0.3,0.3)
	add_child(new_card)

	
func _process(delta):
	new_card.scale.x = fmod(new_card.scale.x +0.1 * delta,0.5)
	new_card.scale.y = fmod(new_card.scale.y +0.1 * delta,0.5)
