class_name DeckData

var name: String
var card_list: Array[CardData] = []


func _init(_name:String= "NAMELESS"):
    self.name = _name

func _to_string():
    return "Deck("+name+")"

func toJSON()-> Dictionary:
    var res_dict = {
        "name" = name,
        "card_list" = card_list
    }
    return res_dict

static func fromJSON(json_data:Dictionary)->DeckData:
    var res: DeckData = DeckData.new(json_data["name"])
    res.card_list = json_data["card_list"]
    return res