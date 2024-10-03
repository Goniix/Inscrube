extends Control

signal FinishedThreadCardCache(card_texture:Texture2D)

var card_scene : PackedScene = preload("res://scenes/card.tscn")
var deck_list : Dictionary = {}
# var selected_deck : DeckListButton = null
var edit_deck_list: Array[CardData] = []

func get_card_texture(card_name:String, file_cache: bool = false):
	var card:Card = card_scene.instantiate()
	card.load_data(RessourceManager.get_card(card_name))
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

func add_deck(_deck_data:DeckData):
	# var new_deck:DeckData = DeckData.new(_name)
	var deck_button:DeckListButton = DeckListButton.new(_deck_data)
	deck_button.pressed.connect(_on_deck_button_pressed.bind(deck_button))
	$DeckList/VBoxContainer.add_child(deck_button)
	deck_list[deck_button] = _deck_data

func save_deck(_deck_data:DeckData):
	var dir = DirAccess.open("user://")
	if !dir.dir_exists("decks"):
		dir.make_dir("decks")
	var save_data = JSON.stringify(_deck_data.toJSON())
	var file = FileAccess.open("user://decks/"+_deck_data.name+".adck",FileAccess.WRITE)
	file.store_line(save_data)
	file.close()

	# var error = ResourceSaver.save(_deck_data, "user://decks/"+_deck_data.name+".adck")
	# if error != OK:
	# 	print(error)

func load_deck(_path:String):
	var file: FileAccess = FileAccess.open(_path,FileAccess.READ)
	var json_data: Dictionary = JSON.parse_string(file.get_line())
	file.close()
	add_deck(DeckData.fromJSON(json_data))

func is_deck_name_valid(deck_name:String):
	if FileAccess.file_exists("user://decks/"+deck_name+".adck"):
		return false
	return true

func _init():
	# FinishedThreadCardCache.connect(_on_finished_thread_card_cache)
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	RessourceManager.loadAllCards()	
	for card_name in RessourceManager.cardData.keys():
		await get_card_texture(card_name)
	
	# add_deck(DeckData.new("Test"))
	reload_deck_list()

func reload_deck_list():
	for child in $DeckList/VBoxContainer.get_children():
		$DeckList/VBoxContainer.remove_child(child)
		child.queue_free()
		
	deck_list.clear()
	for file in DirAccess.get_files_at("user://decks/"):
		load_deck("user://decks/"+file)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Debug1"):
		$CardList.queue_free()

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")


func _on_deck_button_pressed(button:DeckListButton):
	var data = button.deck_data
	edit_deck_list = data.card_list.duplicate()


func _on_save_button_pressed() -> void:
	var deck: DeckData = DeckData.new(%DeckNameInput.text)
	deck.card_list = edit_deck_list
	save_deck(deck)
	print("Saved deck! "+str(deck))
	reload_deck_list()

func _on_deck_name_input_text_changed(new_text:String) -> void:
	%SaveDeckButton.disabled = !is_deck_name_valid(new_text)
