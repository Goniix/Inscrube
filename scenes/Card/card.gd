class_name Card
extends Control


#CARD DATA
var data : CardData
var gameRoot: Game = null
var card_id: String
var card_cost: Dictionary

#ATTACHEMENT VALS
var body_ref
var attached_to = null

#TWEEN DEFINITION
var rotation_tween : Tween = null
var position_tween : Tween = null
var scale_tween : Tween
var color_tween : Tween
var perspective_tween: Tween

#SCALE CONSTS/VALS
const default_scale: Vector2 = Vector2(.22,.22)
var target_scale: Vector2 = default_scale

#PERSPECTIVE SHADER CONSTS/VALS
const perspective_amount: int = 4
var perspective_vec: Vector2

#FRAME CONSTS
static var rarity_to_frame_id: Array = [0,0,1,2,2]

#BG CONSTS
static var rarity_to_bg_id: Array = [0,0,0,1,1]

#GESTURE CONST/VARS
const hold_treshold: float = 0.3
var draggable:bool = false
var dragged:bool = false
var pressed:bool = false
var pressed_timer:float = 0
var press_origin_vector:Vector2 = Vector2.ZERO

func load_data(id: String):
	id = id.to_upper()
	data = Game.cardData[id].duplicate()
	card_id = id
	
	card_cost = {
		CardData.COST_ENUM.BLOOD: Game.cardData[id].blood_cost,
		CardData.COST_ENUM.BONE: Game.cardData[id].bone_cost,
		CardData.COST_ENUM.ENERGY: Game.cardData[id].energy_cost
	}
	update_name()
	update_rarity()
	update_background()
	update_frame()
	update_art()
	update_cost()
	update_stats()
	update_credits()

func update_name():
	%Name.text = get_card_name()

func update_frame():
	%Frame.texture = Game.frames_data[get_card_faction()][rarity_to_frame_id[get_card_rarity()]]
	
func update_background():
	#print(card_faction)
	#print(get_card_rarity())
	%Background.texture = Game.bg_data[get_card_faction()][rarity_to_bg_id[get_card_rarity()]]
	
func update_art():
	%Art.texture = get_card_art()

func update_rarity():
	var rarity_string : String = CardData.RARITY_ENUM.keys()[get_card_rarity()]
	var faction_string :String = CardData.FACTION_ENUM.keys()[get_card_faction()]
	var res = tr("RARITY").format({"rarity":tr(rarity_string),"faction":tr(faction_string)})
	for elem in get_card_sublass():
		res+=tr(CardData.get_subclass(elem).to_upper())+" "
	%Rarity.text = res
	
func update_cost():
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
					
			%CostContainer.add_child(sub_container)

func update_stats():
	%Health.text = str(get_card_life())
	if get_card_attack_type() != CardData.ATTACK_ENUM.NORMAL:
		%Power.text = "A"
	else:
		%Power.text = str(get_card_strength())

func update_credits():
	%Credit.text = "Art: "+get_card_illustrator()+"\nScrybe: "+get_card_scrybe()

func at_least_one_is_slot(list:Array):
	for body in list:
		if body.is_in_group("slot"):
			return true
	return false

func is_slot(elem):
	return elem.is_in_group("slot")

func is_playable() -> bool:
	return is_hovered() and is_affordable() and !$Button.disabled



func is_hovered():
	return $Button.is_hovered()

func get_card_name() -> String:
	return data.card_name
	
func get_card_cost(cost_type : CardData.COST_ENUM) -> int:
	if card_cost.keys().has(cost_type):
		return card_cost[cost_type]
	else:
		return 0

func get_card_sigils() -> Array:
	return data.sigils
	
func get_card_rarity() -> CardData.RARITY_ENUM:
	return data.rarity

func get_card_faction() -> CardData.FACTION_ENUM:
	return data.faction
	
func get_card_sublass() -> Array[CardData.SUBCLASS_ENUM]:
	return data.subclass

func get_card_life() -> int:
	return data.life

func get_card_strength() -> int:
	return data.strength

func get_card_attack_type() -> CardData.ATTACK_ENUM:
	return data.attack_type

func get_card_illustrator() -> String:
	return data.illustrator
	
func get_card_scrybe() -> String:
	return data.scrybe
	
func get_card_art() -> Texture:
	return data.art

func is_affordable():
	#print("Cost is: " + str(card_cost["blood"]))
	#print("Total value is "+gameRoot.get_total_value())
	return get_card_cost(CardData.COST_ENUM.BLOOD)<=gameRoot.get_total_value()

func refresh_draggable(mouse_relative: Vector2) -> void:
	if attached_to != null and attached_to.allow_pick:
		if !position_tween or !position_tween.is_running():
			if is_affordable() and is_hovered() and mouse_relative != Vector2.ZERO:
				draggable = true
				return
	draggable = false

func refresh_scale():
	if attached_to is Slot:
		target_scale = Vector2(.14,.14) * attached_to.get_slot_scale()
	elif attached_to is Hand:
		target_scale = default_scale
		
	if scale_tween and scale_tween.is_running():
		scale_tween.kill()
	scale_tween = create_tween()
	scale_tween.tween_property(self,"scale",target_scale,0.2)

func attach_card(new_slot_body,pos=0):
	if(new_slot_body == null):
		assert(new_slot_body!=null,"Trying to attach card to null Slot!")
		
	if attached_to is Hand:# and not new_slot_body is Hand:
		attached_to.remove_card(self)
	
	elif attached_to is Slot:
		attached_to.attached_card = null
	
	if new_slot_body is Slot:
		new_slot_body.attached_card = self
		
		if position_tween and position_tween.is_running():
			position_tween.kill()
		position_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
		position_tween.tween_property(self,"position", new_slot_body.get_slot_postion()-pivot_offset,0.35)
		
		if rotation_tween and rotation_tween.is_running():
			rotation_tween.kill()
		rotation_tween = create_tween().set_ease(Tween.EASE_OUT)
		rotation_tween.tween_property(self,"rotation", 0,0.1)

		
	elif new_slot_body is Hand:
		#var hand_ref = get_tree().root.get_child(0).get_node("Hand")
		if not new_slot_body.attached_cards.has(self):
			new_slot_body.add_card(self,pos)
		new_slot_body.refresh_cards_pos()
		
	attached_to = new_slot_body
	refresh_scale()

func sacrifice():
	if not attached_to is Slot:
		push_error("Trying to sacrifice an unplayed card!")
	else:
		attached_to.attached_card = null
		queue_free()

func kill():
	pass

func attack(card : Card):
	var attack_properties = trigger_sigils(SigilData.SIGIL_EVENTS.ATTACK_PROPERTY)
	if attack_properties.find(SigilData.ATTACK_PROPERTY.FLYING) != -1 or card==null:
		Game.health_scale += get_card_strength()
		print("attacked scale for "+str(get_card_strength())+" power (scale value="+str(Game.health_scale)+")")
		gameRoot.update_scale()
	else:
		card.damage(get_card_strength())
		print("attacked "+str(card)+" for "+str(get_card_strength())+" power")
		

func damage(amount: int):
	data.life -= amount
	update_stats()

func trigger_sigils(event_triggered : SigilData.SIGIL_EVENTS,target=null)->Array:
	var resArray = []
	for sigil in data.sigils:
		var result = sigil.trigger_event(event_triggered,self,target)
		if(result != null):
			resArray.append(result)

	return resArray

func show_mark():
	$SacrificeMark.change_state(ScarMark.STATES.IDLE)

func hide_mark():
	$SacrificeMark.change_state(ScarMark.STATES.HIDDEN)

func is_sacrificed():
	return $SacrificeMark.is_active()


#CARD CLICK METHOD SELECTION
func play_card_method():
	print(str(self)+" was pressed")
	#if draggable:
	print("Sending "+str(self)+" to play")
	Game.played_card_index = attached_to.attached_cards.find(self)
	attach_card(gameRoot.get_node("PlayedSlot"))
	#_on_mouse_exited()
	gameRoot.on_card_play()
	#else:
		#print("Cannot play "+str(self))


func select_sacrifice_method():
	if $SacrificeMark.state == ScarMark.STATES.IDLE:
		$SacrificeMark.change_state(ScarMark.STATES.ACTIVE)
		gameRoot.sacrificed_value +=1
		gameRoot.activate_sacrifice()
	elif $SacrificeMark.state == ScarMark.STATES.ACTIVE:
		$SacrificeMark.change_state(ScarMark.STATES.IDLE)
		gameRoot.sacrificed_value -=1

func default_card_click_method():
	pass

func get_click_method() -> Callable:
	if gameRoot.card_is_played():
		#print("A card is in play")
		return select_sacrifice_method
	elif attached_to is Hand:
		#print("No card in play")
		return play_card_method
	return default_card_click_method


#ENGINE METHODS
func _ready():
	scale = target_scale
	gameRoot = get_tree().root.get_child(0)

func _process(delta):
	#print(waiting_mouse_move)
	if draggable:
		perspective_vec = Vector2(-perspective_amount,-perspective_amount) + perspective_amount*2*(get_local_mouse_position()/$Button.size)
	
	material.set("shader_parameter/x_rot",-perspective_vec.y)
	material.set("shader_parameter/y_rot",perspective_vec.x)
	
	
	if dragged:
		global_position = get_global_mouse_position()-(size*scale)/2

func _physics_process(delta: float) -> void:
	if draggable and pressed and not dragged:
		if get_global_mouse_position().distance_to(press_origin_vector)>15 or pressed_timer > hold_treshold:
			dragged = true
		else:
			pressed_timer+=delta

func _input(event):
	if event is InputEventMouseMotion:
		refresh_draggable(event.relative)


func _to_string():
	return "Card("+get_card_name()+")"

func _on_card_clicked():
	return
	get_click_method().call()
	
func _on_mouse_entered():
	if scale_tween and scale_tween.is_running():
		scale_tween.kill()
		
	if is_affordable() and !$Button.disabled:
		scale_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		scale_tween.tween_property(self,"scale",target_scale*1.1,0.5)


func _on_mouse_exited():
	if scale_tween and scale_tween.is_running():
		scale_tween.kill()
		
	#if is_affordable():
	scale_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	scale_tween.tween_property(self,"scale",target_scale,0.5)

	if perspective_tween and perspective_tween.is_running():
		perspective_tween.kill()
	
	perspective_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	perspective_tween.tween_property(self,"perspective_vec",Vector2.ZERO,0.5)
	#perspective_vec = Vector2.ZERO
	
	pressed_timer = 0


func _on_button_button_down() -> void:
	pressed = true
	press_origin_vector = get_global_mouse_position()
	#print("mouse:"+str(get_global_mouse_position()))
	#print("card:"+str(global_position))


func _on_button_button_up() -> void:
	pressed = false
	pressed_timer = 0
	press_origin_vector = Vector2.ZERO
	if dragged:
		dragged = false
		_on_mouse_exited()
		if gameRoot.get_hovered_drag_target() != null:
			get_click_method().call()
		else:
			gameRoot.refresh_hand()
		
