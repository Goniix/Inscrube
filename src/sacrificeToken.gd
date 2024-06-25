class_name ScarToken
extends Node2D

var color_tween: Tween
var state : STATES = STATES.IDLE
var hovered: bool = false
var gameRoot = null

enum STATES {IDLE,ACTIVATED}

func get_state_color(node_name):
	if node_name == $SacrificeIcon.name:
		if(is_activated()):
			return Color.RED
		if(hovered):
			return Color.BLACK #Color(0.4875, 0.12, 0.12, 1)
		else:
			return Color.BLACK
	elif node_name == $Token.name:
		if(hovered and OS.get_name() != "Android"):
			return Color.GRAY
		else:
			if(is_activated()):
				return Color.BROWN
			return Color.BLACK
		

func is_activated():
	return state == STATES.ACTIVATED

# Called when the node enters the scene tree for the first time.
func _ready():
	gameRoot = get_tree().root.get_child(0)
	$Token.modulate = Color.BLACK

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("leftClick") and hovered:
		#gameRoot.giveDebugSquirrel()
		if is_activated():
			state = STATES.IDLE
			Game.sacrificed_value = 0;
		else:
			state = STATES.ACTIVATED
			
		Game.allow_card_drag = not is_activated()
		gameRoot.get_node("Hand").refresh_cards_color()
			
		for slot in gameRoot.get_node("SlotsLayer").get_children():
			if(slot.sacrifice_mark_ref != null and slot.attached_card != null):
				slot.sacrifice_mark_ref.change_state(ScarMark.STATES.IDLE if (state == STATES.ACTIVATED) else ScarMark.STATES.HIDDEN)
				
	
	if color_tween == null or !color_tween.is_running():
		if $SacrificeIcon.modulate != get_state_color($SacrificeIcon.name):
			color_tween = create_tween()
			color_tween.tween_property($SacrificeIcon,"modulate",get_state_color($SacrificeIcon.name),0.2)
			
		if $Token.modulate != get_state_color($Token.name):
			color_tween = create_tween()
			color_tween.tween_property($Token,"modulate",get_state_color($Token.name),0.2)
	
func _on_area_2d_mouse_entered():
	hovered = true

func _on_area_2d_mouse_exited():
	hovered = false
