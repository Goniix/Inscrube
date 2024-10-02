extends Control

signal FinishedThreadCardCache(card_texture:Texture2D)

var card_scene : PackedScene = preload("res://scenes/card.tscn")
var deck_list : Dictionary = {}
var selected_deck : DeckListButton = null

func get_card_texture(card_name:String):
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
	# if file_cache:
	# 	card_texture.get_image().save_png("res://cache/"+card_name.to_lower()+".png")
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
	var file = FileAccess.open(_path,FileAccess.READ)
	var json = JSON.new()
	json.parse(file.get_line())
	var json_data: Dictionary = json.get_data()
	add_deck(DeckData.fromJSON(json_data))

func _init():
	# FinishedThreadCardCache.connect(_on_finished_thread_card_cache)
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	RessourceManager.loadAllCards()	
	for card_name in RessourceManager.cardData.keys():
		for i in range(50):
			await get_card_texture(card_name)
	
	add_deck(DeckData.new())
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Debug1"):
		$CardList.queue_free()

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")

# func _on_finished_thread_card_cache(card_texture: Texture2D):
# 	var cardList: ItemList = get_node("CardList")
# 	cardList.add_icon_item(card_texture)

func _on_deck_button_pressed(button:DeckListButton):
	selected_deck = button

func _on_save_button_pressed() -> void:
	var deck: DeckData = deck_list[selected_deck]
	save_deck(deck)
	print("Saved deck! "+str(deck))
