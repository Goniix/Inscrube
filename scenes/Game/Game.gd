class_name Game
extends Node

signal card_dropped(card:Card)

static var cardScene : PackedScene = preload("res://scenes/Card/Card.tscn")
static var slotScene : PackedScene = preload("res://scenes/CardSlot/CardSlot.tscn")
static var sacrificeMarkScene : PackedScene = preload("res://scenes/CardSlot/SacrificeMark/SacrificeMark.tscn")

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

static var hovered_card : Card = null
static var hovered_card_list : Array = []
static var hovered_slot : Slot = null
static var hovered_slot_list = []
static var allow_card_drag : bool = true;
static var card_in_play : bool = false;
static var card_in_play_pos : int = -1
static var sacrificed_value : int = 0

static var health_scale : int = 0
const PLAYER_HEALTH: int = 7

static var player_turn: bool = true
static var player_slots: Array = []
static var opponent_slots: Array = []


const COLOR_DEBUG = false;

static func loadAllCards(recursive:bool=true):
	var cards_dir_list = ["res://cards/card_data"]
	for elem in cards_dir_list:
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

func giveDebugSquirrel():
	var squi = cardScene.instantiate()
	squi.load_data("squirrel")
	$CardLayer.add_child(squi)
	#squi.attach_card($SlotsLayer/TestSlot2)
	squi.attach_card($Hand,$Hand.attached_cards.size())

func get_total_value():
	var total_value = 0
	var slot_list = $SlotsLayer.get_children()
	for slot in slot_list:
		if slot.slot_type == Slot.SLOT_TYPE.PLAYER and slot.attached_card != null:
			total_value+=1
	return total_value

func update_scale():
	$GUI/HealthScale.text = str(health_scale)

func _init():
	Game.loadAllCards(true)
	
func _ready():
	var new_card = cardScene.instantiate()
	new_card.load_data("adder")
	$CardLayer.add_child(new_card)
	#new_card.attach_card($SlotsLayer/TestSlot)
	new_card.attach_card($Hand)
	
	
	var played_slot = $SlotsLayer/PlayedSlot
	played_slot.allow_drop = false
	played_slot.allow_pick = false
	played_slot.allow_sacrifice = false
	

	#for i in range(5):
		#var squi = cardScene.instantiate()
		#squi.load_data("squirrel")
		#$CardLayer.add_child(squi)
		##squi.attach_card($SlotsLayer/TestSlot2)
		#squi.attach_card($Hand)
	
	update_scale()
	
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
		player_slots.append(player_slot)
		
		var opponent_slot = slotScene.instantiate()
		opponent_slot.scale = Vector2(1.5,1.5)
		opponent_slot.rotation = PI
		opponent_slot.slot_index = i
		opponent_slot.slot_type = Slot.SLOT_TYPE.OPPONENT
		opponent_slot.allow_drop = false
		opponent_slot.position = $SlotsPath/PathFollow2D.global_position - Vector2(0,160)
		$SlotsLayer.add_child(opponent_slot)
		opponent_slots.append(opponent_slot)
		
		$Hand.refresh_cards_color()

func _process(delta):
	if(Input.is_action_just_pressed("Debug1")):
		giveDebugSquirrel()
		
	var draggable_card_list = []
	hovered_card_list = []
	for card in $CardLayer.get_children():
		#if(card.hovered):
			#hovered_card_list.append(card)
		if(card.draggable):
			draggable_card_list.append(card)
	
	if len(draggable_card_list) == 0:
		hovered_card = null
	else:
		#Cette ligne ne marchent que si les cartes sont ordonnées dans la main dans le même ordre 
		# qu'elles sont récupérées dans $CardLayer (dernière dans la liste des dragglable = la plus haute)
		hovered_card = draggable_card_list.back()
		
				
	hovered_slot_list = []
	# if card_in_play:
	for slot in $SlotsLayer.get_children():
		if slot.hovered:
			hovered_slot_list.append(slot)

	if len(hovered_slot_list) == 0:
		hovered_slot = null
	else:
		var closest_slot = hovered_slot_list[0]
		for slot in hovered_slot_list:
			var closest_slot_mouse_distance = closest_slot.position.distance_to(get_viewport().get_mouse_position())
			var slot_mouse_distance = slot.position.distance_to(get_viewport().get_mouse_position())
			if  slot_mouse_distance < closest_slot_mouse_distance:
				closest_slot = slot
		hovered_slot = closest_slot
	
	if Input.is_action_just_pressed("leftClick"):
		if card_in_play:
			#left click but a card is already played
			var played_card_ref = $SlotsLayer/PlayedSlot.attached_card #get the played card
			#print(str(played_card_ref)+" already in play")
			if hovered_slot == null or not hovered_slot.allow_drop:
				#no slot are hovered, slot is already filled or slot doesnt allows drop
				print("Sending "+str(played_card_ref)+" back to hand")
				played_card_ref.attach_card($Hand,card_in_play_pos)
				card_in_play = false
				$SacrificeToken.toggle_state()
				
			elif hovered_slot.state == Slot.STATES.ATTACHED :
				if(hovered_slot.sacrifice_mark_ref.is_active()):
						hovered_slot.sacrifice_mark_ref.change_state(ScarMark.STATES.IDLE)					
						sacrificed_value -=1
					
				else:
					if sacrificed_value < played_card_ref.get_cost("blood"):
						sacrificed_value +=1
						hovered_slot.sacrifice_mark_ref.change_state(ScarMark.STATES.ACTIVE)
						print("Activated slot")
				
				if sacrificed_value >= played_card_ref.get_cost("blood"):
					for slot in $SlotsLayer.get_children():
						if slot.sacrifice_mark_ref != null and slot.sacrifice_mark_ref.state == ScarMark.STATES.ACTIVE:
							slot.attached_card.sacrifice()
							
				
			else:
				#slot is valid
				print("Playing "+str(played_card_ref)+"  to "+str(hovered_slot))
				if sacrificed_value >= played_card_ref.get_cost("blood"):
					played_card_ref.attach_card(hovered_slot)
					played_card_ref.modulate = Color(1,1,1,1)
					card_in_play = false
					$GUI/SacrificeToken.toggle_state()
				else:
					print("Cost is not full filled ("+str(sacrificed_value)+"/"+str(played_card_ref.get_cost("blood"))+")")
				
		else:
			print("No card in play")
			if hovered_card != null and hovered_card.draggable and hovered_card.get_affordable():
				print("Sending "+str(hovered_card)+" to play")
				card_in_play_pos = hovered_card.attached_to.attached_cards.find(hovered_card)
				
				hovered_card.attach_card($SlotsLayer/PlayedSlot)
				card_in_play = true
				
				$GUI/SacrificeToken.toggle_state()
				for card in $Hand.attached_cards:
					card.draggable = false
			else:
				print("Cannot play "+str(hovered_card))
		for card in $CardLayer.get_children(): #refresh draggable state of all cards
			card.refresh_draggable()
		$Hand.refresh_cards_pos()
		$Hand.refresh_cards_color()
