class_name Slot
extends StaticBody2D

var slot_index: int
enum SLOT_TYPE {PLAYER,OPPONENT}
var slot_type: SLOT_TYPE
#var attached_card: Card = null
var droppable: bool = true

func _ready():
	$Sprite.modulate = Color.BLACK
