class_name ScarMark
extends TextureRect

var color_tween : Tween = null
enum STATES {HIDDEN,IDLE,HOVERED,ACTIVE}
var state: STATES = STATES.HIDDEN 


func get_state_color():
	match state:
		STATES.HOVERED:
			return Color.RED
		STATES.IDLE:
			return Color.RED
		STATES.HIDDEN:
			return Color(1,0,0,0)
		STATES.ACTIVE:
			return Color.BLACK

func change_state(target_state: STATES):
	if(target_state != state):
		print(str(self)+": Changing to "+str(target_state))
		force_color_change()
		state = target_state

func force_color_change(instant:bool = false):
	color_tween.kill()
	if(instant):
		modulate = get_state_color()
	
func is_active()->bool:
	return state == STATES.ACTIVE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if color_tween == null or !color_tween.is_running():
		if modulate != get_state_color():
			#print("switching to"+str(get_state_color()))
			color_tween = create_tween()
			color_tween.tween_property(self,"modulate",get_state_color(),0.2)

func _to_string():
	return "Mark("+str(get_parent())+")"
