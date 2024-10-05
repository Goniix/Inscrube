static func on_play(source:Card):
	print("Triggered OnPlay from "+str(source))

static func on_attack(_source:Card, _other_card : Card):
	pass

static func attack_property(_source:Card):
	return SigilData.ATTACK_PROPERTY.DEFAULT
