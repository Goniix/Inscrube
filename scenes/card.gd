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
static var frames_path:Dictionary = {
	"Beast": [
		"res://spr/frames/frame_common_beast.png",
		"res://spr/frames/frame_uncommon_beast.png",
		"res://spr/frames/frame_rare_beast.png"
		]
}
static var rarity_to_frame_id: Dictionary = {
	"Common" = 0,
	"Uncommon" = 1,
	"Rare" = 2,
	"Talking" =2
}
#BG CONSTS
static var bg_path:Dictionary = {
	"Beast": [
		"res://spr/bg/bg_common_beast.png",
		"res://spr/bg/bg_rare_beast.png"
		]
}
static var rarity_to_bg_id: Dictionary = {
	"Common" = 0,
	"Uncommon" = 0,
	"Rare" = 1,
	"Talking" = 1
}

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

func update_name():
	$Name.text = card_name

func update_frame():
	$Frame.texture = load(frames_path[card_faction][rarity_to_frame_id[card_rarity]])
	
func update_background():
	$Background.texture = load(bg_path[card_faction][rarity_to_bg_id[card_rarity]])
	
func update_art():
	$Art.texture = load(Game.artData[card_id])

func update_rarity():
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
