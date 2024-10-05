class_name Game
extends Node

@export var cardScene : PackedScene# = preload("res://scenes/card.tscn")
@export var slotScene : PackedScene# = preload("res://scenes/card_slot.tscn")


static var language = 0

static var played_card_index : int = -1
static var sacrificed_value : int = 0

static var health_scale : int = 0
const PLAYER_HEALTH: int = 7

static var player_turn: bool = true

const DEBUG_MODE = true;

static var drag_targets: Array[Node] = []


#static func loadAllCardsJSON(recursive:bool=true):
	#var cards_dir_list = ["res://data/cards/"]
	#for elem in cards_dir_list:
		#var dir = DirAccess.open(elem)
		#if dir:
			#dir.list_dir_begin()
			#var file_name = dir.get_next()
			#while file_name != "":
				#var file_path = dir.get_current_dir()+"/"+file_name
				#if !dir.current_is_dir():
					#var jsonFile = FileAccess.open(file_path,FileAccess.READ)
					#print(jsonFile.get_as_text())
					#var json_parsed:Dictionary = JSON.parse_string(jsonFile.get_as_text())
					#var card_name:String = file_name.replace(".json","")
					#cardData[card_name] = json_parsed
					#print_rich("loaded card [b]"+card_name+"[/b] : [color=YELLOW]"+file_path)
				#elif recursive :
					#cards_dir_list.append(file_path)
				#file_name = dir.get_next()
		#else:
			#print("An error occurred when trying to access the path.")
			
# static func loadAllCards(recursive:bool=false):
# 	var cards_dir_list = ["res://data/cards/"]
# 	for elem in cards_dir_list:
# 		var dir = DirAccess.open(elem)
# 		if dir:
# 			dir.list_dir_begin()
# 			var file_name = dir.get_next()
# 			while file_name != "":
# 				var file_path = dir.get_current_dir()+"/"+file_name
# 				if !dir.current_is_dir():
# 					if '.tres.remap' in file_path:
# 						file_path = file_path.trim_suffix('.remap')
# 					var ressource: CardData = load(file_path)
# 					Global.cardData[ressource.card_name] = ressource
# 					print_rich("loaded card [b]"+ressource.card_name+"[/b] : [color=YELLOW]"+file_path)
# 				elif recursive:
# 					cards_dir_list.append(file_path)
# 				file_name = dir.get_next()
# 		else:
# 			print("An error occurred when trying to access the path.")

#static func dir_contents(path, verbose:bool=false)-> Array[String]:
	#var dir = DirAccess.open(path)
	#var res:Array[String] = []
	#if dir:
		#dir.list_dir_begin()
		#var file_name = dir.get_next()
		#while file_name != "":
			#if dir.current_is_dir():
				#if verbose:
					#print("Found directory: " + file_name)
			#else:
				#if verbose:
					#print("Found file: " + file_name)
				#res.append(file_name)
			#file_name = dir.get_next()
	#else:
		#print("An error occurred when trying to access the path.")
	#return res

func giveCard(card_name: String):
	assert(Global.cardData.keys().has(card_name),card_name + " card_name not found in "+str(Global.cardData.keys()))
	var card = cardScene.instantiate()
	card.load_data(Global.cardData[card_name])
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
	
func is_valid_slot_hovered():
	for slot : Slot in $SlotArea.get_all_slots():
		if slot.is_hovered() and slot.allow_drop:
			return true
	return false

func card_is_played() -> bool:
	return %PlayedSlot.is_attached()

func get_played_card() -> Card:
	return %PlayedSlot.attached_card

func toggle_all_marks(visible:bool):
	for slot : Slot in $SlotArea.get_player_slots():
		if(slot.is_attached()):
			if visible:
				slot.attached_card.show_mark()
			else:
				slot.attached_card.hide_mark()
				
func activate_sacrifice():
	if sacrificed_value == get_played_card().data.get_cost("BLOOD"):
		for slot : Slot in $SlotArea.get_player_slots():
			if slot.is_attached() and slot.allow_sacrifice:
				if slot.attached_card.is_sacrificed():
					slot.attached_card.sacrifice()

func refresh_hand():
	$Hand.refresh_cards_pos(0.4)
	$Hand.refresh_cards_color()

func on_card_play():
	refresh_hand()
	if get_played_card().data.get_cost("BLOOD")>0:
		for slot : Slot in $SlotArea.get_player_slots():
			if slot.is_attached() and slot.allow_sacrifice:
				slot.attached_card.show_mark()

func get_hovered_drag_target():
	for target in drag_targets:
		if target.get_node("Drag target").is_hovered():
			return target
	return null

func _init():
	pass
		
func _ready():
	giveCard("RAVEN")
	giveCard("MAGGOT")

	refresh_hand()

func _process(delta):
	if(Input.is_action_just_pressed("Debug1")):
		giveCard("SQUIRREL")
	if(Input.is_action_just_pressed("Debug2")):
		giveCard("ADDER")
	if(Input.is_action_just_pressed("Debug3")):
		for i in range(85):
			giveCard("SQUIRREL")
		
	if Input.is_action_just_pressed("leftClick"):
		if card_is_played():
			#left click but a card is already played
			
			#print(str(played_card_ref)+" already in play")
			if get_hovered_drag_target() == null:
				#no slot are hovered, slot is already filled or slot doesnt allows drop
				print("Sending "+str(get_played_card())+" back to hand")
				get_played_card().attach_card($Hand,played_card_index)
				refresh_hand()
				
				toggle_all_marks(false)
