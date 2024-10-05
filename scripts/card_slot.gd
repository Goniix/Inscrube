class_name Slot
extends TextureButton

signal state_changed()

var slot_index: int
#enum SLOT_TYPE {PLAYER,OPPONENT}
#@export var slot_type: SLOT_TYPE

@export var allow_drop: bool = true
@export var allow_pick: bool = false
@export var allow_sacrifice: bool = true
var attached_card : Card = null

enum STATES {IDLE,LIGHTED,HOVERED,ATTACHED}
var state: STATES = STATES.IDLE
var gameRoot: Game
#var hovered: bool = false

var color_tween: Tween
var mark_color_tween: Tween

func get_state_color():
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

func is_attached():
	return attached_card != null

func slot_name():
	return str(get_slot_owner())+":"+str(slot_index)

func _ready():
	gameRoot = get_tree().root.get_children().back()
	#$SacrificeMark.visible = false
	emit_signal("state_changed")
	
func get_slot_owner() -> SlotArea.OWNER:
	if get_parent() is GridContainer:
		var slot_area_ref:SlotArea = get_parent().get_parent().get_parent()
		if slot_area_ref.get_player_slots().has(self):
			return SlotArea.OWNER.PLAYER
		else:
			return SlotArea.OWNER.ADVERSE
	else:
		return SlotArea.OWNER.FREE

func _init():
	state_changed.connect(_on_state_changed)

func _process(_delta):
	if is_attached():
		change_state(STATES.ATTACHED)
	elif is_hovered():
		change_state(STATES.HOVERED)
	else:
		change_state(STATES.IDLE)


func get_slot_scale():
	if get_slot_owner()!=SlotArea.OWNER.FREE:
		var slot_area_ref:SlotArea = get_parent().get_parent().get_parent()
		return slot_area_ref.scale
	else:
		return scale

func get_slot_postion() -> Vector2:
	return global_position+(size*get_slot_scale())/2

func _to_string():
	var out = "Slot("+str(get_slot_owner())
	out+=name
	return out+")"

func _on_pressed():
	print(str(self)+" was clicked")
	if gameRoot.card_is_played():
		#slot is valid
		var played_card_ref: Card = gameRoot.get_node("PlayedSlot").attached_card 
		print("Playing "+str(played_card_ref)+"  to "+str(self))
		if Game.sacrificed_value >= played_card_ref.data.get_cost("BLOOD"):
			played_card_ref.attach_card(self)
			played_card_ref.modulate = Color(1,1,1,1)
			played_card_ref.trigger_sigils(SigilData.SIGIL_EVENTS.ON_PLAY)
			#$GUI/SacrificeToken.toggle_state()
			gameRoot.refresh_hand()
			gameRoot.toggle_all_marks(false)
			gameRoot.sacrificed_value = 0
		else:
			print("Cost is not full filled ("+str(Game.sacrificed_value)+"/"+str(played_card_ref.get_card_cost("BLOOD"))+")")


func _on_state_changed():
	color_tween = create_tween()
	color_tween.tween_property(self,"self_modulate",get_state_color(),0.1 if (state == STATES.HOVERED)else 0.3)
	#print("SlotState "+str(state))
	#print("MarkState "+str(mark_sate))
