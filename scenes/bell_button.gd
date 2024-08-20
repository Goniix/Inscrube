class_name BellButton
extends Node2D

enum STATES {IDLE,ACTIVATED}

var token_color_tween: Tween
var icon_color_tween: Tween
var state : STATES = STATES.IDLE
var hovered: bool = false
@export var togglable: bool = true

@export var idle_icon_color: Color = Color.WHITE
@export var hover_icon_color: Color = Color.WHITE
@export var active_icon_color: Color = Color.WHITE

@export var idle_token_color: Color = Color.WHITE
@export var hover_token_color: Color = Color.WHITE
@export var active_token_color: Color = Color.WHITE
var gameRoot = null

func get_state_color(node_name):
	if node_name == $Icon.name:

		if(is_hovered()):
			return hover_icon_color
		if(is_activated()):
			return active_icon_color
		else:
			return idle_icon_color

	elif node_name == $Token.name:

		# if(hovered and OS.get_name() != "Android"):
		# 	return Color.GRAY
		# else:
		# 	if(is_activated()):
		# 		return Color.BROWN
		# 	return Color.BLACK
		if(is_hovered()):
			return hover_token_color
		if(is_activated()):
			return active_token_color
		else:
			return idle_token_color
		

func is_activated():
	return state == STATES.ACTIVATED

func is_hovered():
	return hovered

func activate_button():
	Game.player_turn = !Game.player_turn
	icon_color_tween = create_tween()
	icon_color_tween.tween_property($Icon,"modulate",active_icon_color,0.2)
	var slot_grid = gameRoot.get_node("SlotGrid")
	for slot in slot_grid.get_children():
		if slot.slot_type == Slot.SLOT_TYPE.PLAYER and slot.is_attached():
			slot.attached_card.attack(slot_grid.get_node("O"+slot.name.right(-1)).attached_card)
			
			

func _ready():
	gameRoot = get_tree().root.get_child(0)
	$Token.modulate = Color.BLACK

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("leftClick") and hovered:
		activate_button()
	
	if icon_color_tween == null or !icon_color_tween.is_running():
		if $Icon.modulate != get_state_color($Icon.name):
			icon_color_tween = create_tween()
			icon_color_tween.tween_property($Icon,"modulate",get_state_color($Icon.name),0.2)
			
	if token_color_tween == null or !token_color_tween.is_running():
		if $Token.modulate != get_state_color($Token.name):
			token_color_tween = create_tween()
			token_color_tween.tween_property($Token,"modulate",get_state_color($Token.name),0.2)

func _on_mouse_exited():
	hovered = false


func _on_mouse_entered():
	hovered = true
