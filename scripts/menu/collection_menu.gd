class_name CollectionMenu
extends Control

# signal FinishedThreadCardCache(card_texture:Texture2D)

signal card_added_to_deck(card:CardData)

@export var CardScene : PackedScene
# var selected_deck : DeckListButton = null
static var opened_deck: DeckData = DeckData.new()

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
	if !opened_deck.card_list.keys().has(card.card_name):
		opened_deck.card_list[card.card_name] = 1
	else:
		opened_deck.card_list[card.card_name] = opened_deck.card_list[card.card_name] + 1
	
	print("Added "+str(card)+" to deck ("+str(opened_deck.card_list)+")")

	


func _init():
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	card_added_to_deck.connect($DeckSummary._on_card_added)

	for card_name in Global.cardData.keys():
		get_card_texture(card_name)
	
	# add_deck(DeckData.new("Test"))
	%DeckList.reload_deck_list()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Debug1"):
		$CardList.queue_free()

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scripts/menu/main_menu.tscn")


func _on_save_button_pressed() -> void:
	save_deck(opened_deck)
	print("Saved deck! "+str(opened_deck))
	%DeckList.reload_deck_list()

func _on_deck_name_input_text_changed(new_text:String) -> void:
	# if is_deck_name_valid(new_text):
		# %SaveDeckButton.disabled = false
	opened_deck.deck_name = new_text
	# else:
		# %SaveDeckButton.disabled = true
	
func _on_card_list_item_selected(index:int) -> void:
	$CardList.deselect_all()
	var added_card: CardData = Global.get_card(Global.cardData.keys()[index])
	add_card_to_deck(added_card)
	card_added_to_deck.emit(added_card)

