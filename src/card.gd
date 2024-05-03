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
var card_art_path: String

var draggable = false
var is_in_dropable = false
var body_ref
var offset: Vector2
var initialPos: Vector2

#FRAME CONSTS
static var rarity_to_frame_id: Dictionary = {
	"COMMON" = 0,
	"UNCOMMON" = 1,
	"RARE" = 2,
	"TALKING" =2
}
#BG CONSTS

static var rarity_to_bg_id: Dictionary = {
	"COMMON" = 0,
	"UNCOMMON" = 0,
	"RARE" = 1,
	"TALKING" = 1
}
#COST CONSTS


func load_data(data: Dictionary,id: String):
	card_id = id
	card_name = data["name"]
	card_sigils = data["sigils"]
	card_rarity = data["rarity"]
	card_faction = data["faction"]
	card_subclass = data["subclass"]
	card_cost = data["cost"]
	card_health = data["life"]
	card_power = data["power"]
	card_illustrator = data["illustrator"]
	card_scrybe = data["scrybe"]
	card_art_path = data["art_path"]
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

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	scale = Vector2(0.22,0.22)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if draggable:
		if Input.is_action_just_pressed("leftClick"):
			initialPos = global_position
			offset = get_global_mouse_position() - global_position
			Game.is_dragging = true
		if Input.is_action_pressed("leftClick"):
			global_position = get_global_mouse_position() - offset
			
			var slot_elems = $CollisionArea.get_overlapping_bodies().filter(is_slot)
			if len(slot_elems)>0:
				is_in_dropable = true
				for elem in slot_elems:
					if position.distance_to(elem.position) < position.distance_to(body_ref.position):
						body_ref = elem
				
				for elem in slot_elems:
					if elem != body_ref:
						
						var color_tween = create_tween()
						color_tween.tween_property(elem.get_node("Sprite"),"modulate",Color.BLACK,0.2)
					else:
						var color_tween = create_tween()
						color_tween.tween_property(elem.get_node("Sprite"),"modulate",Color.WHITE,0.2)
			else:
				is_in_dropable = false

		elif Input.is_action_just_released("leftClick"):
			Game.is_dragging = false
			
			var scale_tween = create_tween()
			scale_tween.tween_property(self,"scale",Vector2(0.22,0.22),0.05).set_ease(Tween.EASE_OUT)
			
			var tween = get_tree().create_tween()
			if is_in_dropable:
				tween.tween_property(self,"position", body_ref.position,0.2).set_ease(Tween.EASE_OUT)
				tween.parallel().tween_property(self,"rotation", body_ref.rotation,0.2).set_ease(Tween.EASE_OUT)
			else:
				tween.tween_property(self,"global_position",initialPos,0.2).set_ease(Tween.EASE_OUT)
			
func _on_area_2d_mouse_entered():
	if not Game.is_dragging:
		draggable = true
		var scale_tween = create_tween()
		scale_tween.tween_property(self,"scale",Vector2(0.25,0.25),0.05).set_ease(Tween.EASE_OUT)


func _on_area_2d_mouse_exited():
	if not Game.is_dragging:
		draggable = false
		var scale_tween = create_tween()
		scale_tween.tween_property(self,"scale",Vector2(0.22,0.22),0.05).set_ease(Tween.EASE_OUT)


func _on_area_2d_body_entered(body):
	if body.is_in_group("slot"):
		#is_in_dropable = true
		#var color_tween = create_tween()
		#color_tween.tween_property(body.get_node("Sprite"),"modulate",Color.WHITE,0.2)
		body_ref = body

func _on_area_2d_body_exited(body):
	if body.is_in_group("slot"):
		#if not at_least_one_is_slot($CollisionArea.get_overlapping_bodies()):
			#is_in_dropable = false
			#body_ref = null
		var color_tween = create_tween()
		color_tween.tween_property(body.get_node("Sprite"),"modulate",Color.BLACK,0.2)
