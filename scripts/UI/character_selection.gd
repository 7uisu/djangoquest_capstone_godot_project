extends Node

@onready var male_button = $MaleButton
@onready var female_button = $FemaleButton

# Declare the next scene to load after selection
@export var next_scene_path : String = "res://scenes/UI/name_input.tscn"

# Declare character_data as an autoload.
@onready var character_data = get_node("/root/CharacterData")

func _ready():
	# Ensure character_data autoload is loaded properly
	if character_data == null:
		printerr("ERROR: CharacterData autoload is not correctly loaded! Check the autoload name in Project Settings. Expected: CharacterData")

# Male button pressed
func _on_male_button_pressed() -> void:
	character_data.selected_gender = "male"
	print("Selected gender: " + character_data.selected_gender)

	# Change to the next scene
	get_tree().change_scene_to_file(next_scene_path)

# Female button pressed
func _on_female_button_pressed() -> void:
	character_data.selected_gender = "female"
	print("Selected gender: " + character_data.selected_gender)

	# Change to the next scene
	get_tree().change_scene_to_file(next_scene_path)
