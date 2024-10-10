extends VBoxContainer

var button_list: Dictionary = {} 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_card_added(card:CardData):
	var button : CardButton

	if button_list.keys().has(card.get_card_name()):
		button = button_list[card.get_card_name()]
	else:
		button = CardButton.new()
		button.card_name = card.get_card_name()
		button_list[card.get_card_name()] = button
		$CardSummary/VBoxContainer.add_child(button)

	button.card_count+=1
	button.refresh_text()

func refresh_summary(data: DeckData):
	$CardSummary/VBoxContainer.get_children().clear()
	for key in data.card_list.keys():
		var button = CardButton.new()
		button.card_name = key
		button.card_count = data.card_list[key]
		button_list[key] = button
		$CardSummary/VBoxContainer.add_child(button)

class CardButton:
	extends Button
	var card_name = "NAMELESS"
	var card_count = 0

	func refresh_text():
		text = card_name+": "+str(card_count)
