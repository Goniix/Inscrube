extends Control

func is_hovered():
	var parent: Control = get_parent()
	var mouse: Vector2= get_global_mouse_position()
	
	return Rect2(parent.position, parent.size * parent.scale).has_point(mouse)

func _ready():
	Game.drag_targets.append(get_parent())
