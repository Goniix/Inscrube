extends Node

@export var settingsPath: String
@export var collectionPath: String
@export var mainPath: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file(mainPath)


func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file(settingsPath)


func _on_collection_button_pressed() -> void:
		get_tree().change_scene_to_file(collectionPath)

