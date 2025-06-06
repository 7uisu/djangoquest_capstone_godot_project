extends Control

# References to UI elements
@onready var respawn_button = $RespawnButton
@onready var quit_button = $QuitButton

# Path to main menu scene
const MAIN_MENU_PATH = "res://scenes/UI/main_menu_ui.tscn"

# Vars to find game elements
var player = null
var boss = null

# Called when the node enters the scene tree for the first time.
func _ready():
	# Initially hide the UI
	visible = false
	
	# Connect button signals
	if respawn_button:
		respawn_button.pressed.connect(_on_respawn_button_pressed)
	else:
		print("[RESPAWN_UI_MINIGAME] Error: RespawnButton not found!")
		
	if quit_button:
		quit_button.pressed.connect(_on_quit_button_pressed)
	else:
		print("[RESPAWN_UI_MINIGAME] Error: QuitButton not found!")
	
	# Find game elements
	_find_game_elements()
	
	print("[RESPAWN_UI_MINIGAME] Ready and hidden")

# Find important game elements in the scene
func _find_game_elements():
	# Find player
	player = get_tree().get_first_node_in_group("player")
	if not player:
		player = get_tree().get_root().find_child("Player", true, false)
	
	# Find boss
	boss = get_tree().get_root().find_child("BossSnake", true, false)
	
	# Debug output
	print("[RESPAWN_UI_MINIGAME] Found player: ", player != null)
	print("[RESPAWN_UI_MINIGAME] Found boss: ", boss != null)

# Called when this UI is made visible
func _notification(what):
	if what == NOTIFICATION_VISIBILITY_CHANGED and visible:
		print("[RESPAWN_UI_MINIGAME] Became visible")
		# Ensure player can't move while respawn UI is showing
		_disable_player_movement()
		# Make sure we found all required elements
		if not player:
			_find_game_elements()

# Handle respawn button press
func _on_respawn_button_pressed():
	print("[RESPAWN_UI_MINIGAME] Respawn button pressed")
	
	# Hide the UI just in case it shows during transition
	visible = false
	
	# Get the current scene path
	var current_scene_path = get_tree().current_scene.scene_file_path
	print("[RESPAWN_UI_MINIGAME] Current scene path: ", current_scene_path)
	
	# If for some reason we can't get the path, use hardcoded path
	if current_scene_path.is_empty():
		current_scene_path = "res://Minigame Scenes and Scripts/Chapter 1/chapter_1_world_part_3_2nd_minigame.tscn"
	
	# Create a slight delay to ensure UI is hidden before reload
	await get_tree().create_timer(0.1).timeout
	
	# Complete scene reload - this will reset EVERYTHING to initial state
	print("[RESPAWN_UI_MINIGAME] Reloading entire minigame scene")
	get_tree().change_scene_to_file(current_scene_path)

# Handle quit button press
func _on_quit_button_pressed():
	print("[RESPAWN_UI_MINIGAME] Quit button pressed")
	
	# Wait a short moment before changing scene
	await get_tree().create_timer(0.1).timeout
	
	# Change to main menu scene
	get_tree().change_scene_to_file(MAIN_MENU_PATH)

# Disable player movement
func _disable_player_movement():
	if not player:
		return
		
	print("[RESPAWN_UI_MINIGAME] Disabling player movement")
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
		
	print("[RESPAWN_UI_MINIGAME] Enabling player movement")
	if "can_move" in player:
		player.can_move = true
	elif player.has_method("set_can_move"):
		player.set_can_move(true)
	else:
		# Last resort - restore process mode
		player.process_mode = Node.PROCESS_MODE_INHERIT

# Reset boss and clean up projectiles
func _reset_boss_and_projectiles():
	print("[RESPAWN_UI_MINIGAME] Resetting boss and projectiles")
	
	# Remove all existing projectiles
	var projectiles = get_tree().get_nodes_in_group("projectile")
	if projectiles.size() > 0:
		print("[RESPAWN_UI_MINIGAME] Removing ", projectiles.size(), " projectiles")
		for projectile in projectiles:
			projectile.queue_free()
	
	# Reset boss if found
	if boss:
		# Reset animation state if possible
		if "animated_sprite" in boss and boss.animated_sprite != null:
			if boss.animated_sprite.sprite_frames.has_animation("idle"):
				boss.animated_sprite.play("idle")
		
		# Reset boss position if needed (adjust as necessary)
		# boss.global_position = Vector2(your_preferred_x, your_preferred_y)
		
		# Restart boss behavior
		boss.set_process(true)
		boss.set_physics_process(true)
		
		# Restart all timers
		var timers = [
			boss.get_node_or_null("SmallProjectileTimer"),
			boss.get_node_or_null("MediumProjectileTimer"),
			boss.get_node_or_null("LargeProjectileTimer"),
			boss.get_node_or_null("StateTimer")
		]
		
		for timer in timers:
			if timer:
				timer.start()
				print("[RESPAWN_UI_MINIGAME] Restarted timer: ", timer.name)
