class_name Box
extends Node2D

@export var size:Vector2 = Vector2()
@export_enum("Center","TopLeft") var box_origin: String = "Center"

static func cut_in_slices(length:int,pos_count:int,slice_index:int):
	var slice_size = length/(pos_count-2)
	return slice_size*(slice_index-1)

func get_topleft_postion():
	var res
	match box_origin:
		"Center":
			res = -size*.5
		_:
			res = Vector2()
	return res

func update_child_pos():
	var childs = get_children()
	if(len(childs)>0):
		var i = 0
		for child in childs:
			if child != $Display:
				child.position.x = cut_in_slices(size.x,len(childs),i) + get_topleft_postion().x
			i+=1
	else:
		print("Box does not have childs")

func _ready():
	$Display.position = get_topleft_postion()
	$Display.size = size
	
func _process(delta):
	pass
