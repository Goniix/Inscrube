class_name Selector

signal card_selected

var valid_card_getter: Callable
var test_condition_complete : Callable
var run_on_complete: Callable
var selectable_cards: Array[Card]

func _init(valid_card_getter_method : Callable, test_condition_complete_method : Callable, run_on_complete_method: Callable) -> void:
    valid_card_getter = valid_card_getter_method
    test_condition_complete = test_condition_complete_method
    run_on_complete = run_on_complete_method
    card_selected.connect(_on_card_selected)

func _ready():
    selectable_cards = valid_card_getter.call()

func _on_card_selected():
    pass