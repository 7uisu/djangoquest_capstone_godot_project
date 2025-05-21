# chapter_2_world_part_3.gd
extends Node2D

# Reference to the Microwave node (assuming it's a CharacterBody2D with an AnimatedSprite2D child)
@onready var microwave_animated_sprite: AnimatedSprite2D = $Microwave/AnimatedSprite2D 

# @onready var player: CharacterBody2D = $Player # If needed for direct reference here
# @onready var dialogue_3: Control = $UILayer/Chapter2InteractionDialogue3
# @onready var dialogue_4: Control = $UILayer/Chapter2InteractionDialogue4
# @onready var black_tile: TileMap = $BlackTile # Assuming BlackTile is a TileMap
# @onready var trigger_cutscene_1: Area2D = $Chapter_2_Trigger_Cutscene_1

func _ready() -> void:
	# Chapter2InteractionDialogue3 is set to be visible by default in its own script's _ready function.
	# No specific actions needed here for the initial setup described,
	# as child nodes will initialize themselves.
	print("Chapter 2 World Part 3 Loaded")
	
	# Play the "idle" animation for the Microwave
	if microwave_animated_sprite:
		microwave_animated_sprite.play("idle")
