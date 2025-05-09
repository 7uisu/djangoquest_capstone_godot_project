extends Control

@onready var interaction_dialogue = $InteractionDialogue7

func _ready():
	# Make sure the dialogue system is visible
	if interaction_dialogue:
		interaction_dialogue.visible = true
		# Connect to the dialogue finished signal
		interaction_dialogue.connect("dialogue_finished", _on_dialogue_finished)
		# Start the dialogue immediately
		interaction_dialogue.start_dialogue("start_of_space_journey")

func _on_dialogue_finished():
	# When dialogue is finished, change to the next scene
	# Replace with your next scene path
	get_tree().change_scene_to_file("res://scenes/Hub Area/hub_area.tscn")
