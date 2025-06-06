# respawn_ui_chpater_2.gd
extends Control

@onready var respawn_button = $RespawnButton
@onready var quit_button = $QuitButton
@onready var delivery_bot = get_node("../../YSortLayer/DeliveryBot2")
@onready var instructions_ui = get_node("../Chapter2Minigame1Instructions")

# Set the desired respawn position
var respawn_position = Vector2(454.0, -297.0)

func _ready():
	visible = false
	setup_button_connections()

func setup_button_connections():
	respawn_button.pressed.connect(_on_respawn_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func show_respawn_menu():
	visible = true

func hide_respawn_menu():
	visible = false

func _on_respawn_pressed():
	print("Respawning bot...")
	
	# Reset bot position to specific coordinates and clear trail
	if delivery_bot:
		# Set the specific position you want
		delivery_bot.global_position = respawn_position
		
		# If the bot has a reset_trail method, call it separately
		if delivery_bot.has_method("reset_trail"):
			delivery_bot.reset_trail()
		
		# If the bot has a clear_trail method, call it
		if delivery_bot.has_method("clear_trail"):
			delivery_bot.clear_trail()
		
		delivery_bot.enable_movement()
		print("Bot respawned at: ", respawn_position)
	
	# Reset instructions
	if instructions_ui:
		instructions_ui.reset_instructions()
	
	# Hide this menu
	hide_respawn_menu()

func _on_quit_pressed():
	print("Quitting minigame...")
	
	# Go to main menu
	get_tree().change_scene_to_file("res://scenes/Hub Area/hub_area.tscn")
