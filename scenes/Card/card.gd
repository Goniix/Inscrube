class_name Card
extends Control

var card_id: String
var card_name: String
var card_favor_text: String
var card_sigils: Array #Define type later, dont know how they will be implemented
var card_rarity: int
var card_faction: int
var card_subclass: Array
var card_cost: Dictionary
var card_health: int
var card_attack_type : CardData.ATTACK_ENUM
var card_strength: int
var card_illustrator: String
var card_scrybe: String
var card_art: Texture

var draggable = false
#var hovered = false
var is_in_dropable = false
var body_ref
var offset: Vector2
var attached_to = null
var gameRoot: Game = null

var rotation_tween : Tween = null;
var position_tween : Tween = null;
var color_tween : Tween = null;

#FRAME CONSTS
static var rarity_to_frame_id: Array = [0,0,1,2,2]

#BG CONSTS
static var rarity_to_bg_id: Array = [0,0,0,1,1]


func load_data(id: String):
	card_id = id
	card_name = Game.cardData[id].name
	card_sigils = Game.cardData[id].sigils
	card_rarity = Game.cardData[id].rarity
	card_faction = Game.cardData[id].faction
	card_subclass = Game.cardData[id].subclass
	
	card_cost = {
		CardData.COST_ENUM.BLOOD: Game.cardData[id].blood_cost,
		CardData.COST_ENUM.BONE: Game.cardData[id].bone_cost,
		CardData.COST_ENUM.ENERGY: Game.cardData[id].energy_cost
		}
	
	card_health = Game.cardData[id].life
	card_attack_type = Game.cardData[id].attack_type
	card_strength = Game.cardData[id].strength
	card_illustrator = Game.cardData[id].illustrator
	card_scrybe = Game.cardData[id].scrybe
	card_art = Game.cardData[id].art
	update_background()
	update_frame()
	update_art()
	update_name()
	update_rarity()
	update_cost()
	update_stats()
	update_credits()

func update_name():
	$Name.text = card_name

func update_frame():
	$Frame.texture = Game.frames_data[card_faction][rarity_to_frame_id[card_rarity]]
	
func update_background():
	print(card_faction)
	print(card_rarity)
	$Background.texture = Game.bg_data[card_faction][rarity_to_bg_id[card_rarity]]
	
func update_art():
	$Art.texture = card_art

func update_rarity():
	var rarity_string : String = CardData.RARITY_ENUM.keys()[card_rarity]
	var faction_string :String = CardData.FACTION_ENUM.keys()[card_faction]
	var res = tr("RARITY").format({"rarity":tr(rarity_string),"faction":tr(faction_string)})
	for elem in card_subclass:
		res+=tr(CardData.get_subclass(elem).to_upper())+" "
	$Rarity.text = res
	
func update_cost():
	print(card_cost)
	for key in range(CardData.COST_ENUM.size()):
		if (card_cost[key] > 0):
			var sub_container = HBoxContainer.new()
			sub_container.alignment = BoxContainer.ALIGNMENT_END
			
			if card_cost[key] > 4:
				sub_container.add_theme_constant_override("separation",10)
				
				var stringed_number = str(card_cost[key])
				for charElem in stringed_number:
					var number_icon: TextureRect = TextureRect.new()
					number_icon.texture = Game.cost_data["numbers"][int(charElem)]
					number_icon.custom_minimum_size= Vector2(50,80)
					sub_container.add_child(number_icon)
				
				var x_icon: TextureRect = TextureRect.new()
				x_icon.texture = Game.cost_data["x"]
				x_icon.custom_minimum_size= Vector2(50,80)
				sub_container.add_child(x_icon)
				
				var cost_icon: TextureRect = TextureRect.new()
				cost_icon.texture = Game.cost_data[key]
				cost_icon.custom_minimum_size= Vector2(50,80)
				sub_container.add_child(cost_icon)
			else:
				sub_container.add_theme_constant_override("separation",-10)
				
				for icon in range(card_cost[key]):
					var cost_icon: TextureRect = TextureRect.new()
					cost_icon.texture = Game.cost_icons[key]
					cost_icon.custom_minimum_size= Vector2(50,80)
					sub_container.add_child(cost_icon)
					
			$CostContainer.add_child(sub_container)

func update_stats():
	$Health.text = str(card_health)
	if card_attack_type != CardData.ATTACK_ENUM.NORMAL:
		$Power.text = "A"
	else:
		$Power.text = str(card_strength)

func update_credits():
	$Credit.text = "Art: "+card_illustrator+"\nScrybe: "+card_scrybe

func at_least_one_is_slot(list:Array):
	for body in list:
		if body.is_in_group("slot"):
			return true
	return false

func is_slot(elem):
	return elem.is_in_group("slot")

func is_available(elem):
	var cards_list = get_tree().root.get_child(0).get_node("CardLayer").get_children()
	for card in cards_list:
		if elem == card.attached_to:
			return false
	return elem.allow_drop

func attach_card(new_slot_body,pos=0):
	if(new_slot_body == null):
		push_error("Trying to attach card to null Slot!")
		
	if attached_to is Hand and not new_slot_body is Hand:
		attached_to.remove_card(self)
	
	elif attached_to is Slot:
		attached_to.attached_card = null
	
	if new_slot_body is Slot:
		new_slot_body.attached_card = self		
		if(rotation_tween!=null and rotation_tween.is_running()):
			rotation_tween.kill()
			
		if(new_slot_body.rotation != self.rotation):
			rotation_tween = create_tween()
			rotation_tween.tween_property(self,"rotation", new_slot_body.rotation,0.2).set_ease(Tween.EASE_OUT)
			
		position_tween = create_tween()
		position_tween.tween_property(self,"position", new_slot_body.global_position,0.1).set_ease(Tween.EASE_OUT)
		
	elif new_slot_body is Hand:
		#var hand_ref = get_tree().root.get_child(0).get_node("Hand")
		if not new_slot_body.attached_cards.has(self):
			new_slot_body.add_card(self,pos)
		new_slot_body.refresh_cards_pos()
		
	attached_to = new_slot_body

func is_hovered():
	return $Button.is_hovered()

func refresh_draggable():
	if is_hovered():
		if Game.allow_card_drag:
			if attached_to != null and attached_to.allow_pick:
				draggable = true
	else:
		draggable = false

func get_cost(cost_type : CardData.COST_ENUM):
	return card_cost[cost_type]
	
func get_affordable():
	#print("Cost is: " + str(card_cost["blood"]))
	#print("Total value is "+gameRoot.get_total_value())
	return get_cost(CardData.COST_ENUM.BLOOD)<=gameRoot.get_total_value()

func sacrifice():
	if not attached_to is Slot:
		push_error("Trying to sacrifice an unplayed card!")
	else:
		attached_to.sacrifice_mark_ref.change_state(ScarMark.STATES.HIDDEN)
		attached_to.attached_card = null
		queue_free()

func kill():
	pass

func attack(card : Card):
	if card != null:
		card.damage(card_strength)
		print("attacked "+str(card)+" for "+str(card_strength)+" power")
	else:
		Game.health_scale += card_strength
		print("attacked scale for "+str(card_strength)+" power (scale value="+str(Game.health_scale)+")")
		gameRoot.update_scale()

func damage(amount: int):
	card_health -= amount
	update_stats()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	scale = Vector2(0.22,0.22)
	gameRoot = get_tree().root.get_child(0)

func _process(delta):
	if Game.COLOR_DEBUG:
			if draggable :
				modulate = Color.DARK_GREEN
			else:
				modulate = Color.DARK_MAGENTA
				
	var tween_vector = Vector2(0.23,0.23) if (is_hovered() and get_affordable()) else Vector2(0.22,0.22)
	if tween_vector != scale:
		var scale_tween = create_tween()
		scale_tween.tween_property(self,"scale",tween_vector,0.05).set_ease(Tween.EASE_OUT)
		
	refresh_draggable()
	
	
func _to_string():
	return "Card("+card_name+")"

func _on_card_clicked():
	print(str(self)+" was pressed")
	if !Game.card_in_play:
		print("No card in play")
		if draggable and get_affordable():
			print("Sending "+str(self)+" to play")
			Game.card_in_play_pos = attached_to.attached_cards.find(self)
			attach_card(gameRoot.get_node("PlayedSlot"))
			Game.card_in_play = true
		else:
			print("Cannot play "+str(self))

	gameRoot.on_card_play()
