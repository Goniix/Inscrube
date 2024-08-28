class_name Game
extends Node

static var cardScene : PackedScene = preload("res://scenes/Card/Card.tscn")
static var slotScene : PackedScene = preload("res://scenes/CardSlot/CardSlot.tscn")
static var sacrificeMarkScene : PackedScene = preload("res://scenes/CardSlot/SacrificeMark/SacrificeMark.tscn")

static var cardData : Dictionary = {}
#static var art_data: Dictionary = {
	#"adder": preload("res://assets/art/Adder.png"),
	#"squirrel": preload("res://assets/art/Squirrel.png")
#}
static var frames_data:Array = [
	[
		 preload("res://assets/frames/frame_common_beast.png"),
		 preload("res://assets/frames/frame_uncommon_beast.png"),
		 preload("res://assets/frames/frame_rare_beast.png")
	]
]

static var bg_data:Array = [
	[
		 preload("res://assets/bg/bg_common_beast.png"),
		 preload("res://assets/bg/bg_rare_beast.png")
	]
]
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
}

static var cost_icons: Array = [
	preload("res://assets/cost/blood.png"),
	preload("res://assets/cost/bone.png")
]

static var language = 0

static var allow_card_drag : bool = true;
static var played_card_index : int = -1
static var sacrificed_value : int = 0

static var health_scale : int = 0
const PLAYER_HEALTH: int = 7

static var player_turn: bool = true

const COLOR_DEBUG = false;

static func loadAllCardsJSON(recursive:bool=true):
	var cards_dir_list = ["res://data/cards/"]
	for elem in cards_dir_list:
		var dir = DirAccess.open(elem)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				var file_path = dir.get_current_dir()+"/"+file_name
				if !dir.current_is_dir():
					var jsonFile = FileAccess.open(file_path,FileAccess.READ)
					print(jsonFile.get_as_text())
					var json_parsed:Dictionary = JSON.parse_string(jsonFile.get_as_text())
					var card_name:String = file_name.replace(".json","")
					cardData[card_name] = json_parsed
					print_rich("loaded card [b]"+card_name+"[/b] : [color=YELLOW]"+file_path)
				elif recursive :
					cards_dir_list.append(file_path)
				file_name = dir.get_next()
		else:
			print("An error occurred when trying to access the path.")
			
static func loadAllCards(recursive:bool=false):
	var cards_dir_list = ["res://data/cards/"]
	for elem in cards_dir_list:
		var dir = DirAccess.open(elem)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				var file_path = dir.get_current_dir()+"/"+file_name
				if !dir.current_is_dir():
					var card_name:String = file_name.replace(".tres","")
					cardData[card_name] = load(file_path)
					print_rich("loaded card [b]"+card_name+"[/b] : [color=YELLOW]"+file_path)
				elif recursive:
					cards_dir_list.append(file_path)
				file_name = dir.get_next()
		else:
			print("An error occurred when trying to access the path.")
	
static func dir_contents(path):
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

func giveCard(card_id : String):
	var card = cardScene.instantiate()
	card.load_data(card_id)
	$CardLayer.add_child(card)
	#squi.attach_card($SlotsLayer/TestSlot2)
	card.attach_card($Hand,$Hand.attached_cards.size())
	refresh_hand()

func get_total_value():
	var total_value = 0
	for slot in $SlotArea.get_player_slots():
		if slot.attached_card != null:
			total_value+=1
	return total_value

func update_scale():
	$GUI/HealthScale.text = str(health_scale)
	
func is_valid_slot_hovered():
	for slot : Slot in $SlotArea.get_all_slots():
		if slot.is_hovered() and slot.allow_drop:
			return true
	return false

func card_is_played() -> bool:
	return %PlayedSlot.is_attached()

func get_played_card() -> Card:
	return %PlayedSlot.attached_card

func _init():
	Game.loadAllCards(true)
	
func _ready():
	var new_card: Card = cardScene.instantiate()
	new_card.load_data("raven")
	$CardLayer.add_child(new_card)
	#new_card.attach_card($SlotsLayer/TestSlot)
	new_card.attach_card($Hand)
	
	#new_card = cardScene.instantiate()
	#new_card.load_data("squirrel")
	#$CardLayer.add_child(new_card)
	#new_card.attach_card($SlotArea.get_slot(SlotArea.OWNER.PLAYER,SlotArea.LANE.FRONT,0))
	
	

	update_scale()
	refresh_hand()

func _process(delta):
	if(Input.is_action_just_pressed("Debug1")):
		giveCard("squirrel")
	if(Input.is_action_just_pressed("Debug2")):
		giveCard("adder")
	if(Input.is_action_just_pressed("Debug3")):
		for i in range(85):
			giveCard("squirrel")
		
	#if Input.is_action_just_pressed("leftClick"):
		#if card_is_played():
			##left click but a card is already played
			#
			##print(str(played_card_ref)+" already in play")
			#if !is_valid_slot_hovered():
				##no slot are hovered, slot is already filled or slot doesnt allows drop
				#print("Sending "+str(get_played_card())+" back to hand")
				#get_played_card().attach_card($Hand,played_card_index)
				#refresh_hand()
				#
				#toggle_all_marks(false)

				
				
func refresh_hand():
	$Hand.refresh_cards_pos()
	$Hand.refresh_cards_color()

func on_card_play():
	refresh_hand()
	if get_played_card().card_cost[CardData.COST_ENUM.BLOOD]>0:
		for slot : Slot in $SlotArea.get_player_slots():
			if slot.is_attached() and slot.allow_sacrifice:
				slot.attached_card.show_mark()

func toggle_all_marks(visible:bool):
	for slot : Slot in $SlotArea.get_player_slots():
		if(slot.is_attached()):
			if visible:
				slot.attached_card.show_mark()
			else:
				slot.attached_card.hide_mark()
				
func activate_sacrifice():
	if sacrificed_value == get_played_card().get_card_cost(CardData.COST_ENUM.BLOOD):
		for slot : Slot in $SlotArea.get_player_slots():
			if slot.is_attached() and slot.allow_sacrifice:
				if slot.attached_card.is_sacrificed():
					slot.attached_card.sacrifice()
