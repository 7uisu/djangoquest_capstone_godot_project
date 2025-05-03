#respawn_ui.gd
extends Control

# Reset any collectibles or interactive elements
func _reset_collectibles():
	# Find and reset any pages or collectibles
	var collectibles = get_tree().get_nodes_in_group("collectible")
	for collectible in collectibles:
		if collectible.has_method("reset"):
			collectible.reset()
		else:
			# Default reset behavior
			collectible.visible = true
			if "collected" in collectible:
				collectible.collected = false
	
	# Reset the pages counter in TutorialManager
	var tutorial_manager = get_node_or_null("/root/TutorialManager")
	if tutorial_manager:
		if tutorial_manager.has_method("reset_collected_pages"):
			tutorial_manager.reset_collected_pages()
		else:
			# Fallback if method doesn't exist - just clear the dictionary
			tutorial_manager.collected_pages.clear()
		
		# Update the UI
		if player and "update_pages_label" in player:
			player.update_pages_label()

# Clear any active dialogues that might be showing
func _clear_any_dialogues():
	var dialogues = get_tree().get_nodes_in_group("dialogue")
	for dialogue in dialogues:
		dialogue.queue_free()
	
	# Also try to find specific dialogue instances by name
	var ui_layers = get_tree().get_root().find_children("UILayer", "", true, false)
	for ui_layer in ui_layers:
		for child in ui_layer.get_children():
			if "Dialogue" in child.name:
				child.queue_free()

# References to UI elements
@onready var respawn_button = $RespawnButton
@onready var quit_button = $QuitButton

# Path to main menu scene
const MAIN_MENU_PATH = "res://scenes/UI/main_menu_ui.tscn"

# Vars to find game elements
var idle_snake = null
var chasing_snake = null
var player = null

# Called when the node enters the scene tree for the first time.
func _ready():
	# Initially hide the UI
	visible = false
	
	# Connect button signals
	if respawn_button:
		respawn_button.pressed.connect(_on_respawn_button_pressed)
	else:
		print("[RESPAWN_UI] Error: RespawnButton not found!")
		
	if quit_button:
		quit_button.pressed.connect(_on_quit_button_pressed)
	else:
		print("[RESPAWN_UI] Error: QuitButton not found!")
	
	# Find game elements
	_find_game_elements()
	
	print("[RESPAWN_UI] Ready and hidden")

# Find important game elements
func _find_game_elements():
	# Find player
	player = get_tree().get_first_node_in_group("player")
	if not player:
		player = get_tree().get_root().find_child("Player", true, false)
	
	# Find idle snake
	idle_snake = get_tree().get_first_node_in_group("idle_snake")
	if not idle_snake:
		idle_snake = get_tree().get_root().find_child("IdleSnake", true, false)
	
	# Find chasing snake
	chasing_snake = get_tree().get_root().find_child("ChasingSnake", true, false)
	if not chasing_snake:
		var playground = get_node_or_null("/root/Main/Playground")
		if playground:
			chasing_snake = playground.get_node_or_null("ChasingSnake")
	
	# Debug output
	print("[RESPAWN_UI] Found player: ", player != null)
	print("[RESPAWN_UI] Found idle snake: ", idle_snake != null)
	print("[RESPAWN_UI] Found chasing snake: ", chasing_snake != null)

# Called when this UI is made visible
func _notification(what):
	if what == NOTIFICATION_VISIBILITY_CHANGED and visible:
		print("[RESPAWN_UI] Became visible")
		# Ensure player can't move while respawn UI is showing
		_disable_player_movement()
		# Make sure we found all required elements
		if not player or not idle_snake or not chasing_snake:
			_find_game_elements()

# Handle respawn button press
func _on_respawn_button_pressed():
	print("[RESPAWN_UI] Respawn button pressed")
	
	# Hide the UI
	visible = false
	
	# Reset player to the specific position
	player.global_position = Vector2(613, 3)
	print("[RESPAWN_UI] Resetting player to position (613, 3)")
	
	# Re-enable player movement
	_enable_player_movement()
	
	# Reset the entire chase sequence
	_reset_entire_world()

# Handle quit button press
func _on_quit_button_pressed():
	print("[RESPAWN_UI] Quit button pressed")
	
	# Reset the world before quitting
	_reset_entire_world(false) # Don't activate snake when going to main menu
	
	# Wait a short moment before changing scene
	await get_tree().create_timer(0.1).timeout
	
	# Change to main menu scene
	get_tree().change_scene_to_file(MAIN_MENU_PATH)

# Disable player movement
func _disable_player_movement():
	if not player:
		return
		
	print("[RESPAWN_UI] Disabling player movement")
	if "can_move" in player:
		player.can_move = false
	elif player.has_method("set_can_move"):
		player.set_can_move(false)
	else:
		# Last resort - disable process mode
		player.process_mode = Node.PROCESS_MODE_DISABLED

# Enable player movement
func _enable_player_movement():
	if not player:
		return
		
	print("[RESPAWN_UI] Enabling player movement")
	if "can_move" in player:
		player.can_move = true
	elif player.has_method("set_can_move"):
		player.set_can_move(true)
	else:
		# Last resort - restore process mode
		player.process_mode = Node.PROCESS_MODE_INHERIT

# Reset the entire world - including snake positions
func _reset_entire_world(activate_snake = true):
	print("[RESPAWN_UI] Resetting entire world")
	
	# Reset idle snake
	if idle_snake:
		idle_snake.visible = false  # Keep idle snake hidden after dialogues
		if "position" in idle_snake and "initial_position" in idle_snake:
			idle_snake.position = idle_snake.initial_position
	
	# Reset chasing snake position and state
	if chasing_snake:
		# Reset snake position to the corrected position
		chasing_snake.global_position = Vector2(267, 131)  # Updated position as requested
		print("[RESPAWN_UI] Reset chasing snake position to (267, 131)")
		
		# Reset animation state if possible
		if "animated_sprite" in chasing_snake and chasing_snake.animated_sprite != null:
			if chasing_snake.animated_sprite.sprite_frames.has_animation("idle"):
				chasing_snake.animated_sprite.play("idle")
			elif chasing_snake.animated_sprite.sprite_frames.has_animation("default"):
				chasing_snake.animated_sprite.play("default")
		
		# Reset any other state
		if "is_active" in chasing_snake:
			chasing_snake.is_active = false
			
		# Make sure chasing snake is visible
		chasing_snake.visible = true
		
		# Only activate if requested (not when quitting to menu)
		if activate_snake:
			# Wait a moment before activating
			get_tree().create_timer(0.7).timeout.connect(func():
				if chasing_snake.has_method("activate"):
					chasing_snake.activate()
					print("[RESPAWN_UI] Chasing snake activated")
				else:
					print("[RESPAWN_UI] Error: Chasing snake doesn't have activate method!")
			)
	else:
		print("[RESPAWN_UI] Error: Couldn't find chasing snake to reset!")
		
		# Try to find it again
		chasing_snake = get_tree().get_root().find_child("ChasingSnake", true, false)
		if chasing_snake:
			chasing_snake.global_position = Vector2(267, 131)  # Updated position
			chasing_snake.visible = true
			
			if activate_snake:
				get_tree().create_timer(1.0).timeout.connect(func(): 
					if chasing_snake.has_method("activate"):
						chasing_snake.activate()
				)
			print("[RESPAWN_UI] Found and reset chasing snake on second attempt")
	
	# Reset any other relevant game elements
	_reset_collectibles()
	_clear_any_dialogues()
