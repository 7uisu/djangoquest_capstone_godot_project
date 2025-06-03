#chapter_3_world_part_2.gd
extends Node2D

@onready var ui_layer = $UILayer
@onready var dialogue_2 = $UILayer/Chapter3InteractionDialogue2
@onready var dialogue_3 = $UILayer/Chapter3InteractionDialogue3
@onready var dialogue_5 = $UILayer/Chapter3InteractionDialogue5
@onready var dialogue_4 = $UILayer/Chapter3InteractionDialogue4
@onready var guide_instructions = $UILayer/GuideInstructions
@onready var trigger_cutscene_3 = $Chapter3TriggerCutscene3
@onready var trigger_cutscene_5 = $Chapter3TriggerCutscene5
@onready var cutebot_interactable = $CuteBotInteractable
@onready var player = $Player
@onready var struct3 = $Struct3  # Reference to the TileMapLayer that will be removed

func _ready() -> void:
	# Connect the trigger area signal
	if trigger_cutscene_3:
		trigger_cutscene_3.body_entered.connect(_on_trigger_cutscene_3_body_entered)
		
	if trigger_cutscene_5:
		trigger_cutscene_5.body_entered.connect(_on_trigger_cutscene_5_body_entered)
	
	# Connect CuteBotInteractable interaction signal (not body_entered)
	if cutebot_interactable:
		cutebot_interactable.interacted_with.connect(_on_cutebot_interacted)
	
	# Connect dialogue finished signals if needed
	if dialogue_2:
		dialogue_2.dialogue_finished.connect(_on_dialogue_2_finished)
	if dialogue_3:
		dialogue_3.dialogue_finished.connect(_on_dialogue_3_finished)
	if dialogue_5:
		dialogue_5.dialogue_finished.connect(_on_dialogue_5_finished)
	if dialogue_4:
		dialogue_4.dialogue_finished.connect(_on_dialogue_4_finished)
	
	# Hide guide instructions initially
	if guide_instructions:
		guide_instructions.visible = false
	
	# Start the first dialogue when the world loads
	# Small delay to ensure everything is properly initialized
	await get_tree().process_frame
	start_initial_dialogue()

func start_initial_dialogue() -> void:
	if dialogue_2:
		print("[Chapter3World] Starting initial dialogue...")
		dialogue_2.start_dialogue()

func _on_trigger_cutscene_3_body_entered(body: Node2D) -> void:
	# Check if the player entered the trigger area
	if body == player:
		print("[Chapter3World] Player entered trigger area, starting dialogue 3...")
		if dialogue_3:
			dialogue_3.start_dialogue()
			
func _on_trigger_cutscene_5_body_entered(body: Node2D) -> void:
	# Check if the player entered the trigger area
	if body == player:
		print("[Chapter3World] Player entered trigger area, starting dialogue 5...")
		if dialogue_5:
			dialogue_5.start_dialogue()

# Changed from body_entered to interacted signal
func _on_cutebot_interacted() -> void:
	print("[Chapter3World] Player interacted with CuteBot, starting dialogue 4...")
	if dialogue_4:
		dialogue_4.start_dialogue()

# Optional: Handle when dialogues finish
func _on_dialogue_2_finished() -> void:
	print("[Chapter3World] Dialogue 2 finished")

func _on_dialogue_3_finished() -> void:
	print("[Chapter3World] Dialogue 3 finished")
	
	# Find and remove the Chapter3TriggerCutscene3 node
	var trigger_node = get_node("Chapter3TriggerCutscene3")
	if trigger_node:
		trigger_node.queue_free()
		print("[Chapter3World] Chapter3TriggerCutscene3 removed")
	else:
		print("[Chapter3World] Warning: Chapter3TriggerCutscene3 node not found")
		
func _on_dialogue_5_finished() -> void:
	print("[Chapter3World] Dialogue 5 finished")
	
	# Change this line:
	var trigger_node = get_node("Chapter3TriggerCutscene5")  # Fixed the name
	if trigger_node:
		trigger_node.queue_free()
		print("[Chapter3World] Chapter3TriggerCutscene5 removed")
	else:
		print("[Chapter3World] Warning: Chapter3TriggerCutscene5 node not found")

func _on_dialogue_4_finished() -> void:
	print("[Chapter3World] Dialogue 4 finished - Removing Struct3...")
	
	# Remove Struct3 completely from the scene tree
	if struct3:
		struct3.queue_free()  # This will remove the node completely
		print("[Chapter3World] Struct3 has been removed from the scene")
	else:
		print("[Chapter3World] Warning: Struct3 node not found")
	
	# Show guide instructions after dialogue finishes
	show_guide_instructions()

func show_guide_instructions() -> void:
	if guide_instructions:
		guide_instructions.visible = true
		print("[Chapter3World] Guide instructions shown")
	else:
		print("[Chapter3World] Warning: guide_instructions node not found")
