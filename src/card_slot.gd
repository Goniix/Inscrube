class_name Slot
extends StaticBody2D

var slot_index: int
enum SLOT_TYPE {PLAYER,OPPONENT}
var slot_type: SLOT_TYPE

var allow_drop: bool = true
var allow_pick: bool = true

enum STATES {IDLE,LIGHTED,HOVERED,ATTACHED}
var state: STATES = STATES.IDLE

var color_tween

func get_state_color():
	var res
	match state:
		STATES.IDLE:
			res = Color.BLACK
		STATES.LIGHTED:
			res = Color(0.25, 0.25, 0.25, 1)
		STATES.HOVERED:
			res = Color.WHITE
		STATES.ATTACHED:
			res = Color.BLACK
	return res

func force_color_change():
	color_tween.kill()

func change_state(target_state: STATES):
	if(target_state != state):
		print(slot_name()+" changed state to "+str(target_state))
		state = target_state

func card_exited(card: Card):
	change_state(STATES.IDLE)
	
func is_hovered():
	var card_list = get_tree().root.get_child(0).get_node("CardLayer").get_children()
	for card in card_list:
		if card.body_ref == self and card.is_in_dropable:
			return true
	return false
	
func is_attached():
	var card_list = get_tree().root.get_child(0).get_node("CardLayer").get_children()
	for card in card_list:
		if card.attached_to == self:
			return true
	return false

func slot_name():
	return str(slot_type)+":"+str(slot_index)

func _ready():
	pass

func _process(delta):
	if Game.is_dragging:
		if is_attached():
			change_state(STATES.ATTACHED)
		elif allow_drop:
			if is_hovered():
				change_state(STATES.HOVERED)
			else:
				change_state(STATES.LIGHTED)
	else:
		change_state(STATES.IDLE)
	
	if color_tween == null or !color_tween.is_running():
		if $Sprite.modulate != get_state_color():
			color_tween = create_tween()
			color_tween.tween_property($Sprite,"modulate",get_state_color(),0.2)
			color_tween.finished.connect(_color_change_end.bind(get_state_color()))
			
func _color_change_end(target_color):
	print(slot_name()+" finished changing to "+str(target_color))
