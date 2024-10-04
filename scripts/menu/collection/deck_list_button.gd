extends Button
class_name DeckListButton

var deck_data:DeckData

func _init(_data:DeckData):
    self.deck_data = _data
    self.text = _data.deck_name