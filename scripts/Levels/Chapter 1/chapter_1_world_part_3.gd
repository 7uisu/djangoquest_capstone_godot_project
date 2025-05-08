extends Node2D

@onready var player = $Player
@onready var interaction_dialogue = $UILayer/InteractionDialogue4
@onready var guide_instructions_label = $UILayer/Ch1Pt3GuideInstructionsLabel

func _ready():
	# Disable player movement during initial dialogue
	if player:
		if "can_move" in player:
			player.can_move = false
		else:
			# Fallback to disabling process if can_move property doesn't exist
			player.set_process_input(false)
			player.set_physics_process(false)
	
	# Hide guide instructions initially
	if guide_instructions_label:
		guide_instructions_label.visible = false
	
	# Connect to dialogue finished signal
	if interaction_dialogue:
		interaction_dialogue.connect("dialogue_finished", _on_interaction_dialogue_finished)
		
		# Ensure dialogue is visible
		interaction_dialogue.visible = true
	else:
		push_error("InteractionDialogue4 node not found")

func _on_interaction_dialogue_finished():
	print("Dialogue finished, enabling player movement")
	
	# Enable player movement
	if player:
		if "can_move" in player:
			player.can_move = true
		else:
			# Fallback to enabling process if can_move property doesn't exist
			player.set_process_input(true)
			player.set_physics_process(true)
	
	# Show guide instructions
	if guide_instructions_label:
		guide_instructions_label.visible = true

# Called when player enters the boss snake trigger area
func _on_boss_snake_trigger_entered():
	# This will be called from boss_snake_trigger_cutscene.gd
	print("Boss snake trigger entered, transitioning to next scene")
	# Change to the next scene
	get_tree().change_scene_to_file("res://scenes/Levels/Chapter 1/chapter_1_world_part_3.1.tscn")
