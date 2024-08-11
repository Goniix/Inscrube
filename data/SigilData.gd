class_name SigilData
extends Resource

enum SIGIL_EVENTS {ON_PLAY,ON_ATTACK}

@export var name_id : String
@export var description_id : String
@export var methods : Script = preload("res://data/sigils/scripts/default.gd")

func trigger_event(event:SIGIL_EVENTS,target):
	match event:
		SIGIL_EVENTS.ON_PLAY:
			methods.on_play()
		SIGIL_EVENTS.ON_ATTACK:
			methods.on_attack(target)
