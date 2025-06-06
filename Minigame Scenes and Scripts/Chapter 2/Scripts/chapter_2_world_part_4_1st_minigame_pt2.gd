#chapter_2_world_part_4_1st_minigame_pt2.gd
extends Node2D

@onready var delivery_bot = $YSortLayer/DeliveryBot3
@onready var player = $Player
@onready var instructions_ui = $UILayer/Chapter2Minigame1Instructions

@onready var player_camera = $Player/Camera2D 
@onready var delivery_bot_camera = $YSortLayer/DeliveryBot3/Camera2D 

func _ready():
	print("Chapter2Minigame1: _ready called. Deferring setup_minigame.")
	call_deferred("setup_minigame")

func setup_minigame():
	print("Chapter2Minigame1: setup_minigame called.")
	
	if player:
		player.set_process(false)
		player.set_physics_process(false)
		print("Chapter2Minigame1: Player processing disabled.")
	else:
		printerr("Chapter2Minigame1: Player node not found!")

	if delivery_bot_camera and is_instance_valid(delivery_bot_camera):
		delivery_bot_camera.make_current()
		print("Chapter2Minigame1: DeliveryBot3 camera made current.")
	else:
		printerr("Chapter2Minigame1: DeliveryBot3's Camera2D not found or invalid!")

	if delivery_bot and is_instance_valid(delivery_bot):
		delivery_bot.enable_movement()
		print("Chapter2Minigame1: DeliveryBot3 movement enabled.")
	else:
		printerr("Chapter2Minigame1: DeliveryBot3 node not found or invalid!")

	if instructions_ui:
		instructions_ui.show_default_instructions()
		instructions_ui.visible = true
		print("Chapter2Minigame1: Instructions UI shown.")
	else:
		printerr("Chapter2Minigame1: Instructions UI not found!")

func minigame_completed():
	print("Chapter2Minigame1: Minigame completed.")
	
	if delivery_bot:
		delivery_bot.disable_movement()
		print("Chapter2Minigame1: DeliveryBot3 movement disabled.")

	if player_camera and is_instance_valid(player_camera):
		player_camera.make_current()
		print("Chapter2Minigame1: Player camera made current.")
	
	if player:
		player.set_process(true)
		player.set_physics_process(true)
		print("Chapter2Minigame1: Player processing re-enabled.")

func reset_minigame():
	print("Chapter2Minigame1: Minigame reset.")
	
	if delivery_bot:
		delivery_bot.reset_position_and_trail()
		delivery_bot.disable_movement()
		print("Chapter2Minigame1: DeliveryBot3 reset and disabled.")
	
	if instructions_ui:
		instructions_ui.reset_instructions()
		print("Chapter2Minigame1: Instructions UI reset.")

	if player_camera and is_instance_valid(player_camera):
		player_camera.make_current()
		print("Chapter2Minigame1: Player camera made current.")
	
	if player:
		player.set_process(true)
		player.set_physics_process(true)
		print("Chapter2Minigame1: Player processing re-enabled.")

func show_default_instructions():
	visible = true
	$Label.text = "Help url bot find the right views room."
