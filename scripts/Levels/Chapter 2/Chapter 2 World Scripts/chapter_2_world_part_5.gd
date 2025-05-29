# chapter_2_world_part_5.gd
extends Node2D

# Reference to the Microwave node (assuming it's under YSortLayer/MicrowaveInteractable)
@onready var microwave_interactable = $YSortLayer/MicrowaveInteractable
@onready var microwave_animated_sprite: AnimatedSprite2D = $YSortLayer/MicrowaveInteractable/AnimatedSprite2D

# Reference to dialogue nodes
@onready var dialogue_5: Control = $UILayer/Chapter2InteractionDialogue5
@onready var dialogue_6: Control = $UILayer/Chapter2InteractionDialogue6

func _ready() -> void:
	print("Chapter 2 World Part 5 Loaded")
	
	# Play the "idle" animation for the Microwave initially
	if microwave_animated_sprite:
		microwave_animated_sprite.play("idle")
	
	# Connect dialogue signals if needed
	if dialogue_5:
		dialogue_5.dialogue_finished.connect(_on_dialogue_5_finished)
	if dialogue_6:
		dialogue_6.dialogue_finished.connect(_on_dialogue_6_finished)

func _on_dialogue_5_finished() -> void:
	print("Dialogue 5 finished, transitioning to Dialogue 6")
	# This is handled automatically by dialogue_5's finish_dialogue() method

func _on_dialogue_6_finished() -> void:
	print("Dialogue 6 finished, transitioning to 2nd minigame")
	# This is handled automatically by dialogue_6's finish_dialogue() method
