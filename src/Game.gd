class_name Game
extends Node

signal card_dropped(card:Card)

static var cardScene : PackedScene = preload("res://scenes/card.tscn")
static var slotScene : PackedScene = preload("res://scenes/card_slot.tscn")
static var sacrificeMarkScene : PackedScene = preload("res://scenes/sacrifice_mark.tscn")

static var cardData : Dictionary = {}
static var art_data: Dictionary = {
	"adder": preload("res://assets/art/Adder.png"),
	"squirrel": preload("res://assets/art/Squirrel.png")
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

static var hovered_card = null
static var hovered_card_list = []
static var allow_card_drag = true;
static var sacrificed_value = 0;

const colorDebug = false;

static func loadAllCards(recursive:bool=true):
	var cardsDirs = ["res://cards/card_data"]
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
					print_rich("loaded card [b]"+card_name+"[/b] : [color=YELLOW]"+file_path)
				elif recursive :
					cardsDirs.append(file_path)
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

func giveDebugSquirrel():
	var squi = cardScene.instantiate()
	squi.load_data("squirrel")
	$CardLayer.add_child(squi)
	#squi.attach_card($SlotsLayer/TestSlot2)
	squi.attach_card($Hand)

func _init():
	Game.loadAllCards(true)
	
func _ready():
	
	var new_card = cardScene.instantiate()
	new_card.load_data("adder")
	$CardLayer.add_child(new_card)
	#new_card.attach_card($SlotsLayer/TestSlot)
	new_card.attach_card($Hand)
	
	#for i in range(5):
		#var squi = cardScene.instantiate()
		#squi.load_data("squirrel")
		#$CardLayer.add_child(squi)
		##squi.attach_card($SlotsLayer/TestSlot2)
		#squi.attach_card($Hand)
	
	
	
	for i in range(4):
		$SlotsPath/PathFollow2D.progress_ratio = i/3.0
		
		var player_slot = slotScene.instantiate()
		player_slot.scale = Vector2(1.5,1.5)
		player_slot.slot_index = i
		player_slot.slot_type = Slot.SLOT_TYPE.PLAYER
		player_slot.position = $SlotsPath/PathFollow2D.global_position + Vector2(0,160)
		player_slot.sacrifice_mark_ref = sacrificeMarkScene.instantiate()
		player_slot.sacrifice_mark_ref.position = player_slot.position
		player_slot.sacrifice_mark_ref.slot_ref = player_slot
		#player_slot.allow_pick = false
		$SacrificeMarkLayer.add_child(player_slot.sacrifice_mark_ref)
		$SlotsLayer.add_child(player_slot)
		
		var opponent_slot = slotScene.instantiate()
		opponent_slot.scale = Vector2(1.5,1.5)
		opponent_slot.rotation = PI
		opponent_slot.slot_index = i
		opponent_slot.slot_type = Slot.SLOT_TYPE.OPPONENT
		opponent_slot.allow_drop = false
		opponent_slot.position = $SlotsPath/PathFollow2D.global_position - Vector2(0,160)
		$SlotsLayer.add_child(opponent_slot)

func _process(delta):
	if(Input.is_action_just_pressed("Debug1")):
		giveDebugSquirrel()
		
	var draggable_card_list = []
	hovered_card_list = []
	for card in $CardLayer.get_children():
		if(card.hovered):
			hovered_card_list.append(card)			
		if(card.draggable):
			draggable_card_list.append(card)
	
	if len(draggable_card_list) == 0:
		hovered_card = null
	else:
		for card in draggable_card_list:
			if hovered_card == null or card.position.distance_to(get_viewport().get_mouse_position()):
				hovered_card = card
