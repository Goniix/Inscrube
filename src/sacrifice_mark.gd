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
		force_color_change()
		state = target_state

func force_color_change():
	color_tween.kill()

func _ready():
	set_z_index(20)
	pass # Replace with function body.

func isHovered():
	return slot_ref != null and slot_ref.attached_card != null and slot_ref.attached_card.hovered

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match state:
		STATES.HOVERED:
			if(Input.is_action_just_pressed("leftClick")):
				change_state(STATES.ACTIVE)
				Game.sacrificed_value +=1
			elif not isHovered():
				change_state( STATES.IDLE)
				Game.sacrificed_value -=1
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
