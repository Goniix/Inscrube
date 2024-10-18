class_name CollectionMenu
extends Control

# signal FinishedThreadCardCache(card_texture:Texture2D)

signal card_added_to_deck(card:CardData)

@export var CardScene : PackedScene
var current_deck: DeckData = DeckData.new()
var deck_list : Dictionary = {}
var button_list: Dictionary = {} 

func _init():
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	card_added_to_deck.connect(_on_card_added)
	$DeckList/VBoxContainer/NewDeckButton.connect("pressed", _on_new_deck_button_pressed)

	for card_name in Global.cardData.keys():
		get_card_texture(card_name)
	
	# add_deck(DeckData.new("Test"))
	reload_deck_list()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Debug1"):
		$CardList.queue_free()

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scripts/menu/main_menu.tscn")


func _on_save_button_pressed() -> void:
	save_deck(current_deck)
	print("Saved deck! "+str(current_deck))
	reload_deck_list()

func _on_deck_name_input_text_changed(new_text:String) -> void:
	# if is_deck_name_valid(new_text):
		# %SaveDeckButton.disabled = false
	current_deck.deck_name = new_text
	# else:
		# %SaveDeckButton.disabled = true
	
func _on_card_list_item_selected(index:int) -> void:
	$CardList.deselect_all()
	var added_card: CardData = Global.get_card(Global.cardData.keys()[index])
	add_card_to_deck(added_card)
	card_added_to_deck.emit(added_card)


func _on_new_deck_button_pressed() -> void:
	current_deck = DeckData.new()
	%DeckNameInput.text = ""
	%DeckNameInput.editable = true
	print("New deck!")
	refresh_summary(current_deck)
	
func _on_deck_button_pressed(button:DeckButton):
	var data = button.deck_data
	current_deck = data
	%DeckNameInput.text = data.deck_name
	%DeckNameInput.editable = false
	refresh_summary(current_deck)

func _on_card_added(card:CardData):
	var button : CardSummaryButton

	if button_list.keys().has(card.get_card_name()):
		button = button_list[card.get_card_name()]
	else:
		button = CardSummaryButton.new()
		button.card_name = card.get_card_name()
		button_list[card.get_card_name()] = button
		$DeckSummary/CardSummary/VBoxContainer.add_child(button)

	button.card_count+=1
	button.refresh_text()

func get_card_texture(card_name:String, file_cache: bool = false):
	var card:Card = CardScene.instantiate()
	card.load_data(Global.get_card(card_name))
	add_child(card)
	card.position = Vector2(2000,2000)
	var card_viewport: SubViewport = card.get_node("SubViewportContainer/SubViewport")
	card_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	await RenderingServer.frame_post_draw
	var card_texture: ImageTexture =  ImageTexture.create_from_image(card_viewport.get_texture().get_image())
	# FinishedThreadCardCache.emit(card_texture)
	var cardList: ItemList = get_node("CardList")
	cardList.add_icon_item(card_texture)

	# card_textures.append(card_texture)
	if file_cache:
		var dir = DirAccess.open("user://")
		if !dir.dir_exists("cache"):
			dir.make_dir("cache")
			# for file in DirAccess.get_files_at("user://cache/"):  
			# 	DirAccess.remove_absolute(file)
			# dir.remove("cache")
		var cache_name: String = "user://cache/"+card_name.to_lower()+".png"
		if !FileAccess.file_exists(cache_name):
			card_texture.get_image().save_png(cache_name)

	remove_child(card)
	card.queue_free()


func save_deck(_deck_data:DeckData):
	var dir = DirAccess.open("user://")
	if !dir.dir_exists("decks"):
		dir.make_dir("decks")
	var save_data = JSON.stringify(_deck_data.toJSON())
	print("saving: "+save_data+"to user://decks/"+_deck_data.deck_name+".adck")
	var file = FileAccess.open("user://decks/"+_deck_data.deck_name+".adck",FileAccess.WRITE)
	file.store_line(save_data)
	file.close()

	# var error = ResourceSaver.save(_deck_data, "user://decks/"+_deck_data.deck_name+".adck")
	# if error != OK:
	# 	print(error)



func is_deck_name_valid(deck_name:String):
	if deck_name.is_empty():
		return false
	if FileAccess.file_exists("user://decks/"+deck_name+".adck"):
		return false
	return true

func add_card_to_deck(card:CardData):
	if !current_deck.card_list.keys().has(card.card_name):
		current_deck.card_list[card.card_name] = 1
	else:
		current_deck.card_list[card.card_name] = current_deck.card_list[card.card_name] + 1
	
	print("Added "+str(card)+" to deck ("+str(current_deck.card_list)+")")


func add_deck(_deck_data:DeckData):
	# var new_deck:DeckData = DeckData.new(_name)
	var deck_button:DeckButton = DeckButton.new(_deck_data)
	deck_button.pressed.connect(_on_deck_button_pressed.bind(deck_button))
	$DeckList/VBoxContainer.add_child(deck_button)
	deck_list[deck_button] = _deck_data

func load_deck(_path:String):
	var file: FileAccess = FileAccess.open(_path,FileAccess.READ)
	var json_data: Dictionary = JSON.parse_string(file.get_line())
	file.close()
	add_deck(DeckData.fromJSON(json_data))

func reload_deck_list():
	for child in $DeckList/VBoxContainer.get_children():
		if child is DeckButton:
			$DeckList/VBoxContainer.remove_child(child)
			child.queue_free()

	deck_list.clear()
	for file in DirAccess.get_files_at("user://decks/"):
		load_deck("user://decks/"+file)	

func refresh_summary(data: DeckData):
	print("Refreshing summary")
	print(data.card_list)
	print($DeckSummary/CardSummary/VBoxContainer.get_children())
	for child in $DeckSummary/CardSummary/VBoxContainer.get_children():
		if child is CardSummaryButton:
			$DeckSummary/CardSummary/VBoxContainer.remove_child(child)
			child.queue_free()

	for key in data.card_list.keys():
		var button = CardSummaryButton.new()
		button.card_name = key
		button.card_count = data.card_list[key]
		button_list[key] = button
		button.refresh_text()
		$DeckSummary/CardSummary/VBoxContainer.add_child(button)


class DeckButton:
	extends Button

	var deck_data:DeckData

	func _init(_data:DeckData):
		self.deck_data = _data
		self.text = _data.deck_name


class CardSummaryButton:
	extends Button
	var card_name = "NAMELESS"
	var card_count = 0

	func refresh_text():
		text = card_name+": "+str(card_count)
