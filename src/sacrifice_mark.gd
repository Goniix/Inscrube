extends Node2D

var color_tween : Tween = null
enum STATES {IDLE,HOVERED,ACTIVATED}

var slot_ref : Slot = null

func get_state_color():
	if(slot_ref != null and slot_ref.attached_card != null and slot_ref.attached_card.gameRoot.hovered_card == slot_ref.attached_card):
		return Color.WHITE
	else:
		return Color.BLACK

		

# Called when the node enters the scene tree for the first time.
func _ready():
	set_z_index(20)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if color_tween == null or !color_tween.is_running():
		if $Sprite.modulate != get_state_color():
			color_tween = create_tween()
			color_tween.tween_property($Sprite,"modulate",get_state_color(),0.2)
