class_name SigilData
extends Resource

enum SIGIL_EVENTS {ON_PLAY,ON_ATTACK,ATTACK_PROPERTY}
enum ATTACK_PROPERTY{DEFAULT,FLYING}

@export var name_id : String
@export var description_id : String
@export var methods : Script = preload("res://data/sigils/scripts/default.gd")

func trigger_event(event:SIGIL_EVENTS,source,target):
	var res = null
	match event:
		SIGIL_EVENTS.ON_PLAY:
			if methods.has_method("on_play"):
				methods.on_play(source)
		SIGIL_EVENTS.ON_ATTACK:
			if methods.has_method("on_attack"):
				methods.on_attack(source,target)
		SIGIL_EVENTS.ATTACK_PROPERTY:
			if methods.has_method("attack_propery"):
				res = methods.attack_propery(source)
	return res
