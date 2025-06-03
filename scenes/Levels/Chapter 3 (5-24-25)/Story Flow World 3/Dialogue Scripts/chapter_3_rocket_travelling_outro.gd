# chapter_3_rocket_travelling_outro.gd
extends Control
@onready var fire2: AnimatedSprite2D = $Fire2
@onready var dialogue: Control = $Chapter3RocketTravellingOutroDialogue
@onready var save_manager = get_node("/root/SaveManager") # Added to access SaveManager

func _ready() -> void:
	print("Chapter 3 Rocket Travelling Outro Loaded")
	
	# Start the fire animation
	if fire2:
		fire2.play("default")
	else:
		printerr("Fire2 AnimatedSprite2D not found!")
	
	# Connect dialogue finished signal
	if dialogue:
		dialogue.dialogue_finished.connect(_on_dialogue_finished)
		# The dialogue will start automatically when ready
	else:
		printerr("Chapter3RocketTravellingOutroDialogue not found!")

func _on_dialogue_finished() -> void:
	print("Rocket travelling outro dialogue finished")
	print("Attempting to unlock Chapter 4.")
	
	# --- UNLOCK CHAPTER 4 ---
	if save_manager:
		# We are unlocking Chapter 4, so the argument is 4.
		# This updates CharacterData for the current session.
		save_manager.unlock_level_in_character_data(4)
		
		# IMPORTANT: For this unlock to persist after quitting the game,
		# you MUST save the game data.
		# You might want to call save_manager.save_game(current_slot, {}) here
		# if you have a way to know the current_slot.
		# Otherwise, the unlock will only last for the current play session.
		print("Chapter 4 unlocked in CharacterData (for this session). Remember to save the game for persistence!")
		
		# Example of how you might save if you have a current slot stored, e.g., in CharacterData
		# var character_data = get_node("/root/CharacterData")
		# if character_data and character_data.has_method("get_current_save_slot") and character_data.get_current_save_slot() != -1:
		# 	if save_manager.save_game(character_data.get_current_save_slot(), {}):
		# 		print("Game progress saved. Chapter 4 unlock is now persistent.")
		# 	else:
		# 		printerr("Failed to save game after unlocking chapter.")
		# else:
		# 	print("No active save slot found or CharacterData not configured to provide it. Unlock is not saved to disk yet.")
	else:
		printerr("SaveManager not found! Cannot unlock Chapter 4.")
	# --- END UNLOCK CHAPTER 4 ---
	
	# The scene transition is handled in the dialogue script itself
	# Or you can add your own scene transition here if needed
	# get_tree().change_scene_to_file("res://scenes/your_next_scene.tscn")
