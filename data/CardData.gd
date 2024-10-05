class_name CardData
extends Resource

enum RARITY_ENUM{SIDEDECK,COMMON,UNCOMMON,RARE,TALKING}
enum FACTION_ENUM{BEAST,TECH,UNDEAD,MAGICK}
enum SUBCLASS_ENUM{ANT,AVIAN,INSECT,HOOVED,CANINE,REPTILE,VERMIN,FISH,AMPHIBIAN,CONDUIT,NOBLE,MACHINE,TENTACLE,HOUND,ALL,CRYPTID,MOX,WIZARD,ALTAR,MAGE,OUTLAW,SAGE,CORRUPTED,KNIGHT,FLOWER,ABERRATION,SPECTRE,CONSTRUCT,CULTIST,ANDROID,POSESSED,SKELETON,MECHABEAST,BOT,LATCHER,CELL,LEEP,CHESS,PIRATE,ZOMBIE,DEMON,EMPLOYEE,PUMPKIN,}
const COST_ENUM: Array[String] = ["BLOOD","BONE","ENERGY"]
enum ATTACK_ENUM{NORMAL}
@export var card_name : String
var favor_text : String = card_name + "_FAVOR"
@export var sigils : Array[SigilData]
@export var rarity : RARITY_ENUM
@export var faction : FACTION_ENUM
@export var subclass : Array[SUBCLASS_ENUM]
@export var cost : Dictionary = {"BLOOD" : 0,"BONE" : 0,"ENERGY" : 0}
@export var life : int
@export var attack_type : ATTACK_ENUM
@export var strength : int
@export var illustrator : String = "Pixel Profligate"
@export var scrybe : String = "Answearing Machine"
@export var art : Texture = preload("res://assets/art/zerror.png")

static func subclass_tostring(subclass_index:SUBCLASS_ENUM) -> String:
	var stringed = [
	"ant",
	"avian",
	"insect",
	"hooved",
	"canine",
	"reptile",
	"vermin",
	"fish",
	"amphibian",
	"conduit",
	"noble",
	"machine",
	"tentacle",
	"hound",
	"all",
	"cryptid",
	"mox",
	"wizard",
	"altar",
	"mage",
	"outlaw",
	"sage",
	"corrupted",
	"knight",
	"flower",
	"aberration",
	"spectre",
	"construct",
	"cultist",
	"android",
	"posessed",
	"skeleton",
	"mechabeast",
	"bot",
	"latcher",
	"cell",
	"leep",
	"chess",
	"pirate",
	"zombie",
	"demon",
	"employee",
	"pumpkin"
	]
	return stringed[subclass_index]

func get_card_name() -> String:
	return card_name

func get_favor_text()-> String:
	return card_name + "_FAVOR"

func get_sigils() -> Array[SigilData]:
	return sigils

func get_rarity()->RARITY_ENUM:
	return rarity

func get_faction()->FACTION_ENUM:
	return faction

func get_subclass()->Array[SUBCLASS_ENUM]:
	return subclass

func get_cost(cost_type: String)->int:
	if COST_ENUM.has(cost_type):
		return cost[cost_type]
	else:
		return -1

func get_cost_all() -> Dictionary:
	return cost

func get_life()-> int:
	return life

func get_attack_type()->ATTACK_ENUM:
	return attack_type

func get_strength()->int:
	return strength

func get_illustrator()->String:
	return illustrator

func get_scrybe() -> String:
	return "Pixel Profligate"

func get_art()-> Texture:
	return art

# func get_()->:
# 	return 

func rarity_to_string()->String:
	const rarities : Array[String] = ["common","common","uncommon","rare","rare"]
	return  rarities[get_rarity()]

func faction_to_string()->String:
	const factions : Array[String] = ["beast","tech","undead","magick"]
	return  factions[get_faction()]