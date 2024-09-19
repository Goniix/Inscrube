class_name Selector

signal card_selected

var valid_card_getter: Callable
var test_condition_complete: Callable
var run_on_select: Callable
var run_on_complete: Callable
var selectable_cards: Array[Card]


func _init(valid_card_getter_method: Callable, test_condition_complete_method: Callable, run_on_select_method: Callable, run_on_complete_method: Callable) -> void:
	#get set callable methods
	valid_card_getter = valid_card_getter_method
	test_condition_complete = test_condition_complete_method
	run_on_select = run_on_select_method
	run_on_complete = run_on_complete_method
	
	card_selected.connect(_on_card_selected)

func _ready():
	selectable_cards = valid_card_getter.call()

#sent from card when selected
func _on_card_selected() -> void:
	var is_complete: bool = test_condition_complete.call()
	run_on_select.call()
	if is_complete:
		run_on_complete.call()
