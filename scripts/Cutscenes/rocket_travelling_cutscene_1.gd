extends Control

@onready var interaction_dialogue = $InteractionDialogue7
@onready var save_manager = get_node("/root/SaveManager") # Added to access SaveManager

func _ready():
	# Make sure the dialogue system is visible
	if interaction_dialogue:
		interaction_dialogue.visible = true
		# Connect to the dialogue finished signal
		# Ensure the signal name "dialogue_finished" matches what InteractionDialogue7 actually emits.
		if not interaction_dialogue.is_connected("dialogue_finished", Callable(self, "_on_dialogue_finished")):
			interaction_dialogue.connect("dialogue_finished", Callable(self, "_on_dialogue_finished"))
		
		# Start the dialogue immediately
		# Ensure "start_of_space_journey" is a valid dialogue ID in your InteractionDialogue7 node.
		interaction_dialogue.start_dialogue("start_of_space_journey")
	else:
		printerr("InteractionDialogue7 node not found!")

func _on_dialogue_finished():
	print("Dialogue finished. Attempting to unlock Level 2.")
	
	# --- MODIFICATION START: Unlock Level 2 ---
	if save_manager:
		# We are unlocking Level 2, so the argument is 2.
		# This updates CharacterData for the current session.
		save_manager.unlock_level_in_character_data(2)
		
		# IMPORTANT: For this unlock to persist after quitting the game,
		# you MUST save the game data.
		# You might want to call save_manager.save_game(current_slot, {}) here
		# if you have a way to know the current_slot.
		# Otherwise, the unlock will only last for the current play session.
		print("Level 2 unlocked in CharacterData (for this session). Remember to save the game for persistence!")
		
		# Example of how you might save if you have a current slot stored, e.g., in CharacterData
		# var character_data = get_node("/root/CharacterData")
		# if character_data and character_data.has_method("get_current_save_slot") and character_data.get_current_save_slot() != -1:
		# 	if save_manager.save_game(character_data.get_current_save_slot(), {}):
		# 		print("Game progress saved. Level 2 unlock is now persistent.")
		# 	else:
		# 		printerr("Failed to save game after unlocking level.")
		# else:
		# 	print("No active save slot found or CharacterData not configured to provide it. Unlock is not saved to disk yet.")

	else:
		printerr("SaveManager not found! Cannot unlock Level 2.")
	# --- MODIFICATION END ---

	# When dialogue is finished, change to the next scene
	# Replace with your next scene path
	get_tree().change_scene_to_file("res://scenes/Hub Area/hub_area.tscn")
