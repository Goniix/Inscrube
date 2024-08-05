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

func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#var played_card_slot = get_tree().root.get_child(0).get_node("PlayedSlot")
	#match state:
		#STATES.IDLE:
			#if is_hovered() and Game.sacrificed_value < played_card_slot.attached_card.get_cost("blood"):
				#change_state(STATES.HOVERED)
		#STATES.HOVERED:
			#if not is_hovered():
				#change_state(STATES.IDLE)
		#
	if color_tween == null or !color_tween.is_running():
		if modulate != get_state_color():
			#print("switching to"+str(get_state_color()))
			color_tween = create_tween()
			color_tween.tween_property(self,"modulate",get_state_color(),0.2)
