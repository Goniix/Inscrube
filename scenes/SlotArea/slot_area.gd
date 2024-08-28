class_name SlotArea
extends Control

enum OWNER {PLAYER,ADVERSE,FREE}
enum LANE {BACK,FRONT}
const row_count = 4

var hovered: bool = false

func get_player_slots() -> Array[Node]:
	return $ArrayContainers/PlayerSlots.get_children()
	
func get_adverse_slots() -> Array[Node]:
	return $ArrayContainers/AdverseSlots.get_children()

func get_all_slots() -> Array[Node]:
	return get_player_slots() + get_adverse_slots()

func get_slot(owner:OWNER, lane:LANE, row:int) -> Slot:
	assert(0<=row and row<row_count, "Invalid row number. exepected: between 0 and "+str(4)+" got "+str(row))
	var slot_id:String = ""
	slot_id+="F" if (lane == LANE.FRONT) else "B"
	slot_id+=str(row)
	if(owner == OWNER.PLAYER):
		return $ArrayContainers/PlayerSlots.get_node(slot_id)
	else:
		return $ArrayContainers/AdverseSlots.get_node(slot_id)

func find_slot(slot:Slot):
	return get_all_slots().find(slot)


func _on_mouse_entered():
	hovered = true


func _on_mouse_exited():
	hovered = false
