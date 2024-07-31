extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_pressed():
	Game.player_turn = !Game.player_turn
	var gameRoot = get_tree().root.get_child(0)
	for i in range(4):
		if Game.player_slots[i].is_attached():
			print(Game.player_slots[i].attached_card)
			Game.player_slots[i].attached_card.attack(Game.opponent_slots[i].attached_card)
