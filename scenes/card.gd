class_name Card
extends Control

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
var card_art_path: String

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
	card_art_path = data["art_path"]
	update_background()
	update_frame()
	update_art()
	update_name()
	update_rarity()
	update_cost()

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
				for char in stringed_number:
					var number_icon: TextureRect = TextureRect.new()
					number_icon.texture = Game.cost_data["numbers"][int(char)]
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
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
