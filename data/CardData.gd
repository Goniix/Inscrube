class_name CardData
extends Resource

enum RARITY_ENUM{SIDEDECK,COMMON,UNCOMMON,RARE,TALKING}
enum FACTION_ENUM{BEAST,TECH,UNDEAD,MAGICK}
enum SUBCLASS_ENUM{ANT,AVIAN,INSECT,HOOVED,CANINE,REPTILE,VERMIN,FISH,AMPHIBIAN,CONDUIT,NOBLE,MACHINE,TENTACLE,HOUND,ALL,CRYPTID,MOX,WIZARD,ALTAR,MAGE,OUTLAW,SAGE,CORRUPTED,KNIGHT,FLOWER,ABERRATION,SPECTRE,CONSTRUCT,CULTIST,ANDROID,POSESSED,SKELETON,MECHABEAST,BOT,LATCHER,CELL,LEEP,CHESS,PIRATE,ZOMBIE,DEMON,EMPLOYEE,PUMPKIN,}
enum COST_ENUM{BLOOD,BONE,ENERGY}
enum ATTACK_ENUM{NORMAL}
@export var card_name : String
var favor_text : String = card_name + "_FAVOR"
@export var sigils : Array[SigilData]
@export var rarity : RARITY_ENUM
@export var faction : FACTION_ENUM
@export var subclass : Array[SUBCLASS_ENUM]
@export var blood_cost : int
@export var bone_cost : int
@export var energy_cost : int
@export var life : int
@export var attack_type : ATTACK_ENUM
@export var strength : int
@export var illustrator : String = "Pixel Profligate"
@export var scrybe : String = "Answearing Machine"
@export var art : Texture = preload("res://assets/art/zerror.png")

static func get_subclass(subclass_index:SUBCLASS_ENUM) -> String:
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
