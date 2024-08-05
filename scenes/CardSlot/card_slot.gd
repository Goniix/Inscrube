class_name Slot
extends TextureButton

signal state_changed()

var slot_index: int
enum SLOT_TYPE {PLAYER,OPPONENT}
@export var slot_type: SLOT_TYPE

@export var allow_drop: bool = true
@export var allow_pick: bool = false
@export var allow_sacrifice: bool = true
var attached_card : Card = null

enum STATES {IDLE,LIGHTED,HOVERED,ATTACHED}
var state: STATES = STATES.IDLE
var gameRoot 
#var hovered: bool = false

var color_tween: Tween
var mark_color_tween: Tween

func get_state_color( state : STATES):
	var res
	match state:
		STATES.IDLE:
			res = Color.BLACK
		STATES.LIGHTED:
			res = Color(0.25, 0.25, 0.25, 1)
		STATES.HOVERED:
				res = Color(0.3,0,0)
		STATES.ATTACHED:
			res = Color.BLACK
	return res

func force_color_change():
	if color_tween != null:
		color_tween.kill()

func change_state(target_state: STATES):
	if(target_state != state):
		#print(slot_name()+" changed state to "+str(target_state))
		state = target_state
		emit_signal("state_changed")
		tooltip_text = str(state)

func is_attached():
	return attached_card != null

func slot_name():
	return str(slot_type)+":"+str(slot_index)

func _ready():
	gameRoot = get_tree().root.get_child(0)
	#$SacrificeMark.visible = false
	emit_signal("state_changed")
	
func is_player_slot():
	return slot_type == SLOT_TYPE.PLAYER

func _process(delta):
	if is_attached():
		change_state(STATES.ATTACHED)
	elif is_hovered():
		change_state(STATES.HOVERED)
	else:
		change_state(STATES.IDLE)

func show_mark():
	$SacrificeMark.change_state(ScarMark.STATES.IDLE)

func hide_mark():
	$SacrificeMark.change_state(ScarMark.STATES.HIDDEN)
		

func _to_string():
	var out = "Slot("+str(slot_type)
	if slot_type == SLOT_TYPE.PLAYER:
		out+=str(gameRoot.get_node("SlotGrid").get_children().find(self))
	return out+")"

func _on_pressed():
	print(str(self)+" was clicked")
	if state != STATES.ATTACHED:
		if Game.card_in_play:
			#slot is valid
			var played_card_ref = gameRoot.get_node("PlayedSlot").attached_card 
			print("Playing "+str(played_card_ref)+"  to "+str(self))
			if Game.sacrificed_value >= played_card_ref.get_cost(CardData.COST_ENUM.BLOOD):
				played_card_ref.attach_card(self)
				played_card_ref.modulate = Color(1,1,1,1)
				played_card_ref.get_node("Button").disabled = true
				Game.card_in_play = false
				#$GUI/SacrificeToken.toggle_state()
				gameRoot.refresh_hand()
			else:
				print("Cost is not full filled ("+str(Game.sacrificed_value)+"/"+str(played_card_ref.get_cost("blood"))+")")


func _on_state_changed():
	color_tween = create_tween()
	color_tween.tween_property(self,"self_modulate",get_state_color(state),0.1 if (state == STATES.HOVERED)else 0.3)
	#print("SlotState "+str(state))
	#print("MarkState "+str(mark_sate))
