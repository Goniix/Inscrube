class_name Game
extends Node

static var cardScene : PackedScene = preload("res://scenes/card.tscn")
static var slotScene : PackedScene = preload("res://scenes/card_slot.tscn")

static var cardData : Dictionary = {}
static var art_data: Dictionary = {
	"adder": preload("res://assets/art/Adder.png")
}
static var frames_data:Dictionary = {
	"BEAST": [
		 preload("res://assets/frames/frame_common_beast.png"),
		 preload("res://assets/frames/frame_uncommon_beast.png"),
		 preload("res://assets/frames/frame_rare_beast.png")
		]
}
static var bg_data:Dictionary = {
	"BEAST": [
		 preload("res://assets/bg/bg_common_beast.png"),
		 preload("res://assets/bg/bg_rare_beast.png")
		]
}
static var cost_data: Dictionary = {
	"x": preload("res://assets/cost/x.png"),
	"numbers" : [
		preload("res://assets/cost/0.png"),
		preload("res://assets/cost/1.png"),
		preload("res://assets/cost/2.png"),
		preload("res://assets/cost/3.png"),
		preload("res://assets/cost/4.png"),
		preload("res://assets/cost/5.png"),
		preload("res://assets/cost/6.png"),
		preload("res://assets/cost/7.png"),
		preload("res://assets/cost/8.png"),
		preload("res://assets/cost/9.png")
	],
	"blood": preload("res://assets/cost/blood.png"),
	"bone": preload("res://assets/cost/bone.png")
	
}

static var language = 0

static var is_dragging = false

static func loadAllCards(recursive:bool=true):
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




func _init():
	Game.loadAllCards(true)
	
func _ready():
	var new_card
	new_card = cardScene.instantiate()
	new_card.position = Vector2(300,400)
	new_card.load_data(cardData["adder"],"adder")
	$CardLayer.add_child(new_card)
	new_card.attach_card($SlotsLayer/TestSlot)
	
	
	for i in range(4):
		$SlotsPath/PathFollow2D.progress_ratio = i/3.0
		
		var player_slot = slotScene.instantiate()
		player_slot.scale = Vector2(1.5,1.5)
		player_slot.slot_index = i
		player_slot.slot_type = Slot.SLOT_TYPE.PLAYER
		player_slot.get_node("Sprite").modulate = Color.BLACK
		player_slot.position = $SlotsPath/PathFollow2D.global_position + Vector2(0,160)
		$SlotsLayer.add_child(player_slot)
		
		var opponent_slot = slotScene.instantiate()
		opponent_slot.scale = Vector2(1.5,1.5)
		opponent_slot.rotation = PI
		opponent_slot.slot_index = i
		opponent_slot.slot_type = Slot.SLOT_TYPE.OPPONENT
		opponent_slot.droppable = false
		opponent_slot.get_node("Sprite").modulate = Color.BLACK
		opponent_slot.position = $SlotsPath/PathFollow2D.global_position - Vector2(0,160)
		$SlotsLayer.add_child(opponent_slot)

func _process(delta):
	pass
