extends Control

@onready var name_input = $LineEdit
@onready var confirm_button = $ConfirmButton

# Declare character_data as an autoload.
@onready var character_data = get_node("/root/CharacterData")

# Declare the next scene to load after this one.
@export var next_scene : String = "res://playground.tscn"

func _ready():
	# No need to manually connect signals, it's done in the editor
	# Just ensure character_data is properly loaded
	if character_data == null:
		printerr("ERROR: CharacterData autoload is not correctly loaded! Check the autoload name in Project Settings. Expected: CharacterData")

func _on_confirm_button_pressed() -> void:
	var player_name = name_input.text.strip_edges() # Corrected method to remove spaces.

	if player_name.length() > 0: # check if name is not empty
		character_data.player_name = player_name # Store the name in the autoload.
		print("Player name: " + character_data.player_name)
		get_tree().change_scene_to_file(next_scene) # Go to the next scene.
	else:
		print("Player name cannot be empty!")
		# You can display a message to the player here, like:
		#$Label.text = "Please enter a name!"
