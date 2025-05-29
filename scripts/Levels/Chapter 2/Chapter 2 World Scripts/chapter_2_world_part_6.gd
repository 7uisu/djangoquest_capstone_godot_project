# chapter_2_world_part_6.gd
extends Node2D

# References to scene elements
@onready var bat: CharacterBody2D = $Bat
@onready var bat_animated_sprite: AnimatedSprite2D = $Bat/AnimatedSprite2D
@onready var microwave_interactable = $YSortLayer/MicrowaveInteractable
@onready var microwave_animated_sprite: AnimatedSprite2D = $YSortLayer/MicrowaveInteractable/AnimatedSprite2D

# Reference to dialogue nodes
@onready var dialogue_7: Control = $UILayer/Chapter2InteractionDialogue7
@onready var dialogue_8: Control = $UILayer/Chapter2InteractionDialogue8

func _ready() -> void:
	print("Chapter 2 World Part 6 Loaded")
	
	# Set initial positions and animations
	if bat:
		# Set bat to initial position (off-screen)
		bat.position = Vector2(1334.0, -422.0)
		
		# Play idle animation for bat
		if bat_animated_sprite:
			bat_animated_sprite.play("idle")
	
	# Play idle animation for microwave (GRIT is recovered now)
	if microwave_animated_sprite:
		microwave_animated_sprite.play("idle")
	
	# Connect dialogue signals
	if dialogue_7:
		dialogue_7.dialogue_finished.connect(_on_dialogue_7_finished)
	if dialogue_8:
		dialogue_8.dialogue_finished.connect(_on_dialogue_8_finished)

func _on_dialogue_7_finished() -> void:
	print("Dialogue 7 finished, transitioning to Dialogue 8")
	# This is handled automatically by dialogue_7's finish_dialogue() method

func _on_dialogue_8_finished() -> void:
	print("Dialogue 8 finished, transitioning to chapter_2_world_part_7")
	# This is handled automatically by dialogue_8's finish_dialogue() method
