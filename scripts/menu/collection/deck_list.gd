extends PanelContainer

var deck_list : Dictionary = {}
@export var deckNameInputField: LineEdit


func add_deck(_deck_data:DeckData):
	# var new_deck:DeckData = DeckData.new(_name)
	var deck_button:DeckButton = DeckButton.new(_deck_data)
	deck_button.pressed.connect(_on_deck_button_pressed.bind(deck_button))
	$VBoxContainer.add_child(deck_button)
	deck_list[deck_button] = _deck_data

func load_deck(_path:String):
	var file: FileAccess = FileAccess.open(_path,FileAccess.READ)
	var json_data: Dictionary = JSON.parse_string(file.get_line())
	file.close()
	add_deck(DeckData.fromJSON(json_data))

func reload_deck_list():
	for child in $VBoxContainer.get_children():
		if child is DeckButton:
			$VBoxContainer.remove_child(child)
			child.queue_free()

	deck_list.clear()
	for file in DirAccess.get_files_at("user://decks/"):
		load_deck("user://decks/"+file)	

func _on_deck_button_pressed(button:DeckButton):
	var data = button.deck_data
	CollectionMenu.opened_deck = data
	deckNameInputField.text = data.deck_name
	deckNameInputField.editable = false

func _on_new_deck_button_pressed() -> void:
	CollectionMenu.opened_deck = DeckData.new()
	deckNameInputField.text = ""
	deckNameInputField.editable = true

class DeckButton:
	extends Button

	var deck_data:DeckData

	func _init(_data:DeckData):
		self.deck_data = _data
		self.text = _data.deck_name
