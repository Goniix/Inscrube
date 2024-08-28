static func on_play(source:Card):
	print("Triggered OnPlay from "+str(source))

static func on_attack(source:Card, other_card : Card):
	pass

static func attack_propery(source:Card):
	return SigilData.ATTACK_PROPERTY.DEFAULT
