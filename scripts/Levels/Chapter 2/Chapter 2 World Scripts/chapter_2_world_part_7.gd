# chapter_2_world_part_7.gd
extends Node2D

# References to scene elements
@onready var bat: CharacterBody2D = $Bat
@onready var bat_animated_sprite: AnimatedSprite2D = $Bat/AnimatedSprite2D
@onready var microwave_interactable = $YSortLayer/MicrowaveInteractable
@onready var microwave_animated_sprite: AnimatedSprite2D = $YSortLayer/MicrowaveInteractable/AnimatedSprite2D

# Reference to dialogue nodes
@onready var dialogue_9: Control = $UILayer/Chapter2InteractionDialogue9
@onready var dialogue_10: Control = $UILayer/Chapter2InteractionDialogue10

func _ready() -> void:
	print("Chapter 2 World Part 7 Loaded")
	
	# Set initial positions and animations
	if bat:
		# Set bat to initial position (off-screen)
		bat.position = Vector2(245.0, 61.0)
		
		# Play idle animation for bat
		if bat_animated_sprite:
			bat_animated_sprite.play("idle")
	
	# Play idle animation for microwave (GRIT is recovered now)
	if microwave_animated_sprite:
		microwave_animated_sprite.play("idle")
	
	# Connect dialogue signals
	if dialogue_9:
		dialogue_9.dialogue_finished.connect(_on_dialogue_9_finished)
	if dialogue_10:
		dialogue_10.dialogue_finished.connect(_on_dialogue_10_finished)
	
	# Start the first dialogue automatically when scene loads
	if dialogue_9:
		dialogue_9.start_this_dialogue("tower_top")

func _on_dialogue_9_finished() -> void:
	print("Dialogue 9 finished, transitioning to Dialogue 10")
	# This is handled automatically by dialogue_9's finish_dialogue() method

func _on_dialogue_10_finished() -> void:
	print("Dialogue 10 finished, chapter complete")
	# This is handled automatically by dialogue_10's finish_dialogue() method
	# which changes to the next scene (Chapter 3)
