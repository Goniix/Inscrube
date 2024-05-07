class_name Card
extends Node2D

var card_id: String
var card_name: String
var card_favor_text: String
var card_sigils: Array #Define type later, dont know how they will be implemented
var card_rarity: String
var card_faction: String
var card_subclass: Array
var card_cost: Dictionary
var card_health: int
var card_power: Dictionary
var card_illustrator: String
var card_scrybe: String

var draggable = false
var is_in_dropable = false
var body_ref
var offset: Vector2
var attached_to = null

#FRAME CONSTS
static var rarity_to_frame_id: Dictionary = {
	"SIDE_DECK" = 0,
	"COMMON" = 0,
	"UNCOMMON" = 1,
	"RARE" = 2,
	"TALKING" =2
}
#BG CONSTS

static var rarity_to_bg_id: Dictionary = {
	"SIDE_DECK" = 0,
	"COMMON" = 0,
	"UNCOMMON" = 0,
	"RARE" = 1,
	"TALKING" = 1
}
#COST CONSTS


func load_data(id: String):
	card_id = id
	card_name = Game.cardData[id]["name"]
	card_sigils = Game.cardData[id]["sigils"]
	card_rarity = Game.cardData[id]["rarity"]
	card_faction = Game.cardData[id]["faction"]
	card_subclass = Game.cardData[id]["subclass"]
	card_cost = Game.cardData[id]["cost"]
	card_health = Game.cardData[id]["life"]
	card_power = Game.cardData[id]["power"]
	card_illustrator = Game.cardData[id]["illustrator"]
	card_scrybe = Game.cardData[id]["scrybe"]
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
	$Background.texture = Game.bg_data[card_faction][rarity_to_bg_id[card_rarity]]
	
func update_art():
	$Art.texture = Game.art_data[card_id]

func update_rarity():
	var res = tr("RARITY").format({"rarity":tr(card_rarity),"faction":tr(card_faction)})
	for elem in card_subclass:
		res+=tr(elem)+" "
	$Rarity.text = res
	
func update_cost():
	for key in card_cost.keys():
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
					cost_icon.texture = Game.cost_data[key]
					cost_icon.custom_minimum_size= Vector2(50,80)
					sub_container.add_child(cost_icon)
					
			$CostContainer.add_child(sub_container)

func update_stats():
	$Health.text = str(card_health)
	if card_power["alt"] != null:
		$Power.text = "A"
	else:
		$Power.text = str(card_power["value"])

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

func attach_card(new_slot_body):
	if attached_to is Hand:
		#var hand_ref = get_tree().root.get_child(0).get_node("Hand")
		attached_to.remove_card(self)
		
	
	if new_slot_body is Slot:
		var tween = create_tween()
		tween.tween_property(self,"position", new_slot_body.position,0.1).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(self,"rotation", new_slot_body.rotation,0.2).set_ease(Tween.EASE_OUT)
	elif new_slot_body is Hand:
		#var hand_ref = get_tree().root.get_child(0).get_node("Hand")
		if not new_slot_body.attached_cards.has(self):
			new_slot_body.add_card(self)
		new_slot_body.refresh_cards_pos()
		
	attached_to = new_slot_body

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	scale = Vector2(0.22,0.22)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if draggable:
		if Input.is_action_just_pressed("leftClick"):
			offset = get_global_mouse_position() - global_position
			Game.is_dragging = true
			get_tree().root.get_child(0).get_node("CardLayer").move_child(self,-1)
			
			if rotation!=0:
				var tween = create_tween()
				tween.parallel().tween_property(self,"rotation", 0,0.2).set_ease(Tween.EASE_OUT)
			
		if Input.is_action_pressed("leftClick"):
			global_position = get_global_mouse_position() - offset
			
			var slot_elems = $CollisionArea.get_overlapping_bodies().filter(is_slot).filter(is_available)
			if len(slot_elems)>0:
				is_in_dropable = true
				for elem in slot_elems:
					if position.distance_to(elem.position) < position.distance_to(body_ref.position):
						body_ref = elem
					
			else:
				is_in_dropable = false

		elif Input.is_action_just_released("leftClick"):
			Game.is_dragging = false
			
			if is_in_dropable:
				attach_card(body_ref)
			else:
				attach_card(attached_to)
			
			var tween = get_tree().create_tween()
			tween.parallel().tween_property(self,"scale",Vector2(0.22,0.22),0.05).set_ease(Tween.EASE_OUT)

func _on_area_2d_mouse_entered():
	if not Game.is_dragging:
		if attached_to != null and attached_to.allow_pick:
			draggable = true
			var scale_tween = create_tween()
			scale_tween.tween_property(self,"scale",Vector2(0.23,0.23),0.05).set_ease(Tween.EASE_OUT)

func _on_area_2d_mouse_exited():
	if not Game.is_dragging:
		draggable = false
		var scale_tween = create_tween()
		scale_tween.tween_property(self,"scale",Vector2(0.22,0.22),0.05).set_ease(Tween.EASE_OUT)

func _on_area_2d_body_entered(body):
	if body.is_in_group("slot"):
		body_ref = body

func _on_area_2d_body_exited(body):
	if body.is_in_group("slot"):
		body.card_exited(self)
