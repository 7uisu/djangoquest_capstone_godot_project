# chapter_3_world_part_3.gd
extends Node2D

@onready var ui_layer = $UILayer
@onready var dialogue_6 = $UILayer/Chapter3InteractionDialogue6
@onready var dialogue_7 = $UILayer/Chapter3InteractionDialogue7
@onready var guide_instructions = $UILayer/GuideInstructions
@onready var cutebot_interactable = $CuteBotInteractable
@onready var player = $Player
@onready var struct3 = $Struct3  # Reference to the TileMapLayer that will be removed

func _ready() -> void:
	# Connect CuteBotInteractable interaction signal with safety check
	if cutebot_interactable:
		# Check if the signal exists before connecting
		if cutebot_interactable.has_signal("interacted_with"):
			cutebot_interactable.interacted_with.connect(_on_cutebot_interacted)
			print("[Chapter3World] Successfully connected to interacted_with signal")
		else:
			print("[Chapter3World] ERROR: interacted_with signal not found on CuteBotInteractable")
			print("[Chapter3World] Available signals: ", cutebot_interactable.get_signal_list())
	
	# Connect dialogue finished signals with safety checks
	if dialogue_6:
		if dialogue_6.has_signal("dialogue_finished"):
			dialogue_6.dialogue_finished.connect(_on_dialogue_6_finished)
			print("[Chapter3World] Successfully connected to dialogue_6.dialogue_finished signal")
		else:
			print("[Chapter3World] ERROR: dialogue_finished signal not found on dialogue_6")
			print("[Chapter3World] Available signals on dialogue_6: ", dialogue_6.get_signal_list())
	
	if dialogue_7:
		if dialogue_7.has_signal("dialogue_finished"):
			dialogue_7.dialogue_finished.connect(_on_dialogue_7_finished)
			print("[Chapter3World] Successfully connected to dialogue_7.dialogue_finished signal")
		else:
			print("[Chapter3World] ERROR: dialogue_finished signal not found on dialogue_7")
			print("[Chapter3World] Available signals on dialogue_7: ", dialogue_7.get_signal_list())

# Optional: Keep this function in case you want to start dialogue_6 from elsewhere
func start_initial_dialogue() -> void:
	if dialogue_6:
		print("[Chapter3World] Starting initial dialogue...")
		dialogue_6.start_dialogue()

# Changed to start dialogue_7 instead of dialogue_6
func _on_cutebot_interacted() -> void:
	print("[Chapter3World] Player interacted with CuteBot, starting dialogue 7...")
	if dialogue_7:
		dialogue_7.start_dialogue()

# Optional: Handle when dialogues finish
func _on_dialogue_6_finished() -> void:
	print("[Chapter3World] Dialogue 6 finished")
	
func _on_dialogue_7_finished() -> void:
	print("[Chapter3World] Dialogue 7 finished, transitioning to next scene...")
	# Transition to the next scene
	get_tree().change_scene_to_file("res://scenes/Levels/Chapter 3 (5-24-25)/Story Flow World 3/chapter_3_world_part_4.tscn")
