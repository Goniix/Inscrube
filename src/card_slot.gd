class_name Slot
extends Area2D

var slot_index: int
enum SLOT_TYPE {PLAYER,OPPONENT}
var slot_type: SLOT_TYPE

var allow_drop: bool = true
var allow_pick: bool = false
var allow_sacrifice: bool = true
var attached_card : Card = null

var sacrifice_mark_ref: Node2D = null;

enum STATES {IDLE,LIGHTED,HOVERED,ATTACHED}
var state: STATES = STATES.IDLE
var hovered: bool = false

var color_tween: Tween

func get_state_color():
	var res
	match state:
		STATES.IDLE:
			res = Color.BLACK
		STATES.LIGHTED:
			res = Color(0.25, 0.25, 0.25, 1)
		STATES.HOVERED:
			#res = Color.WHITE
			res = Color(0.15,0,0)
		STATES.ATTACHED:
			res = Color.BLACK
	return res

func force_color_change():
	color_tween.kill()

func change_state(target_state: STATES):
	if(target_state != state):
		#print(slot_name()+" changed state to "+str(target_state))
		state = target_state
		force_color_change()

func card_exited(card: Card):
	change_state(STATES.IDLE)
	
func is_hovered():
	return hovered#and Game.hovered_slot == self
	
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
	if is_attached():
		change_state(STATES.ATTACHED)
	elif is_hovered():
		change_state(STATES.HOVERED)
	else:
		change_state(STATES.IDLE)
	#if Game.card_in_play:
		#if is_attached():
			#change_state(STATES.ATTACHED)
		#elif allow_drop:
			#if is_hovered():
				#change_state(STATES.HOVERED)
			#else:
				#change_state(STATES.LIGHTED)
	#else:
		#change_state(STATES.IDLE)
	
	if color_tween == null or !color_tween.is_running():
		if $Sprite.modulate != get_state_color():
			color_tween = create_tween()
			color_tween.tween_property($Sprite,"modulate",get_state_color(),0.1 if (state == STATES.HOVERED)else 0.3)
			#color_tween.finished.connect(_color_change_end.bind(get_state_color()))

func _on_mouse_entered():
	hovered = true

func _on_mouse_exited():
	hovered = false
