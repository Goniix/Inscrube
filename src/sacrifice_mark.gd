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
			return Color.WHITE
		STATES.IDLE:
			return Color.BLACK
		STATES.HIDDEN:
			return Color.TRANSPARENT
		STATES.ACTIVE:
			return Color.RED

func change_state(target_state: STATES):
	if(target_state != state):
		state = target_state

func _ready():
	set_z_index(20)
	pass # Replace with function body.

func isHovered():
	return slot_ref != null and slot_ref.attached_card != null and slot_ref.attached_card.hovered

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print(state)
	match state:
		STATES.HOVERED:
			if(Input.is_action_just_pressed("leftClick")):
				change_state(STATES.ACTIVE)
			elif not isHovered():
				change_state( STATES.IDLE)
		STATES.IDLE:
			if(isHovered()):
				change_state( STATES.HOVERED)
		STATES.ACTIVE:
			if(isHovered() and Input.is_action_just_pressed("leftClick")):
				change_state(STATES.HOVERED)
			
		
	
	if color_tween == null or !color_tween.is_running():
		if $Sprite.modulate != get_state_color():
			#print("switching to"+str(get_state_color()))
			color_tween = create_tween()
			color_tween.tween_property($Sprite,"modulate",get_state_color(),0.2)
