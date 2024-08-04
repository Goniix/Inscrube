class_name ScarMark
extends Node2D

var color_tween : Tween = null
enum STATES {HIDDEN,IDLE,HOVERED,ACTIVE}
var state: STATES = STATES.HIDDEN 

var slot_ref : Slot = null

#func setHidden(value : bool):
	#color_tween = create_tween()
	#color_tween.tween_property($Sprite,"modulate",Color(0,0,0,0 if (isHidden) else 1),0.2) 

func get_state_color():
	match state:
		STATES.HOVERED:
			return Color.RED
		STATES.IDLE:
			return Color(1,0,0,0)
		STATES.HIDDEN:
			return Color.TRANSPARENT
		STATES.ACTIVE:
			return Color.BLACK

func change_state(target_state: STATES):
	if(target_state != state):
		force_color_change()
		state = target_state

func force_color_change(instant:bool = false):
	color_tween.kill()
	if(instant):
		$Sprite.modulate = get_state_color()

func is_active():
	return state == STATES.ACTIVE

func _ready():
	set_z_index(20)
	pass # Replace with function body.

func is_hovered():
	return slot_ref != null and slot_ref.attached_card != null and slot_ref.attached_card.hovered

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var played_card_slot = get_tree().root.get_child(0).get_node("SlotsLayer/PlayedSlot")
	match state:
		STATES.IDLE:
			if is_hovered() and Game.sacrificed_value < played_card_slot.attached_card.get_cost("blood"):
				change_state(STATES.HOVERED)
		STATES.HOVERED:
			if not is_hovered():
				change_state(STATES.IDLE)
		
	
	if color_tween == null or !color_tween.is_running():
		if $Sprite.modulate != get_state_color():
			#print("switching to"+str(get_state_color()))
			color_tween = create_tween()
			color_tween.tween_property($Sprite,"modulate",get_state_color(),0.2)
