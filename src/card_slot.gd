class_name Slot
extends StaticBody2D

var slot_index: int
enum SLOT_TYPE {PLAYER,OPPONENT}
var slot_type: SLOT_TYPE
#var attached_card: Card = null
var droppable: bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
