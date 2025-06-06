extends Node2D

@onready var hearts_container = $UILayer/HeartsContainer
@onready var respawn_ui = $UILayer/RespawnUIWorld1Minigame2
@onready var guide_instructions_label = $UILayer/GuideInstructionsLabel
@onready var save_manager = get_node("/root/SaveManager")

# Configure max health
var max_health = 3
var current_health = 3
var game_active = true
var player_invulnerable = false
@export var invulnerability_time: float = 2.0  # Seconds of invulnerability after hit
@export var next_scene: String = "res://Minigame Scenes and Scripts/Chapter 1/chapter_1_world_part_4.tscn"  # Path to the next scene

func _ready():
	# Initialize hearts display with correct values
	if hearts_container:
		hearts_container.max_hearts = max_health
		hearts_container.current_hearts = current_health
		hearts_container.setup_hearts()
		print("[MINIGAME_MANAGER] Hearts initialized: ", current_health, "/", max_health)
	else:
		print("[MINIGAME_MANAGER] ERROR: Could not find hearts container!")
	
	# Make sure respawn UI is hidden at start
	if respawn_ui:
		respawn_ui.visible = false
		print("[MINIGAME_MANAGER] RespawnUI hidden")
		
		# Connect visibility changed signal to ensure guide instructions stay hidden
		respawn_ui.visibility_changed.connect(_on_respawn_ui_visibility_changed)
	else:
		print("[MINIGAME_MANAGER] ERROR: Could not find respawn UI!")
	
	# Make sure guide instructions label is visible at start
	if guide_instructions_label:
		guide_instructions_label.visible = true
		print("[MINIGAME_MANAGER] GuideInstructionsLabel shown")
	else:
		print("[MINIGAME_MANAGER] ERROR: Could not find guide instructions label!")
		# Try to find it by name if not at expected path
		guide_instructions_label = get_tree().get_root().find_child("GuideInstructionsLabel", true, false)
		if guide_instructions_label:
			guide_instructions_label.visible = true
			print("[MINIGAME_MANAGER] Found GuideInstructionsLabel on second attempt")
	
	# Ensure player can move at start
	var player = get_tree().get_first_node_in_group("player")
	if player and "can_move" in player:
		player.can_move = true

# Function to handle damage to player
func take_damage(amount: int):
	# If game is not active or player is invulnerable, ignore damage
	if !game_active or player_invulnerable:
		print("[MINIGAME_MANAGER] Damage ignored - game inactive or player invulnerable")
		return
	
	print("[MINIGAME_MANAGER] Taking damage: ", amount)
	current_health -= amount
	
	# Update hearts display
	if hearts_container:
		hearts_container.update_hearts(current_health)
		print("[MINIGAME_MANAGER] Hearts updated: ", current_health, "/", max_health)
	
	# Check if player has lost all hearts
	if current_health <= 0:
		_on_player_defeated()
	else:
		# Make player invulnerable for a short time
		_start_invulnerability()

# Make player invulnerable for a short time after taking damage
func _start_invulnerability():
	player_invulnerable = true
	print("[MINIGAME_MANAGER] Player invulnerable started for ", invulnerability_time, " seconds")
	
	# Get player node
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		player = get_tree().get_root().find_child("Player", true, false)
	
	# Flash player to indicate invulnerability
	if player:
		_flash_player(player)
	
	# Create timer for invulnerability duration
	get_tree().create_timer(invulnerability_time).timeout.connect(func():
		player_invulnerable = false
		print("[MINIGAME_MANAGER] Player invulnerability ended")
		
		# Make sure player is fully visible when invulnerability ends
		if player and player.visible == false:
			player.visible = true
	)

# Flash player sprite to indicate invulnerability
func _flash_player(player_node):
	# Don't continue if game is over
	if !game_active:
		return
		
	# Do nothing if player no longer exists
	if not is_instance_valid(player_node):
		return
		
	# Toggle visibility
	player_node.visible = !player_node.visible
	
	# Continue flashing only if still invulnerable
	if player_invulnerable:
		get_tree().create_timer(0.15).timeout.connect(func():
			_flash_player(player_node)
		)
	else:
		# Ensure player is visible when invulnerability ends
		player_node.visible = true

# Function to handle player defeat
func _on_player_defeated():
	print("[MINIGAME_MANAGER] Player defeated!")
	game_active = false
	
	# Pause boss attacks/movement if needed
	var boss = get_tree().get_root().find_child("BossSnake", true, false)
	if boss:
		# Disable boss behavior
		boss.set_process(false)
		boss.set_physics_process(false)
		
		# Stop all timers
		var timers = [
			boss.get_node_or_null("SmallProjectileTimer"),
			boss.get_node_or_null("MediumProjectileTimer"),
			boss.get_node_or_null("LargeProjectileTimer"),
			boss.get_node_or_null("StateTimer")
		]
		for timer in timers:
			if timer:
				timer.stop()
	
	# Show respawn UI
	if respawn_ui:
		print("[MINIGAME_MANAGER] Showing respawn UI")
		respawn_ui.visible = true
		
		# Ensure guide instructions are hidden when respawn UI is shown
		if guide_instructions_label:
			guide_instructions_label.visible = false
			print("[MINIGAME_MANAGER] GuideInstructionsLabel hidden because respawn UI is visible")
	else:
		print("[MINIGAME_MANAGER] ERROR: Could not find respawn UI for game over!")
		# Emergency fallback - try to find it by name
		respawn_ui = get_tree().get_root().find_child("RespawnUI", true, false)
		if respawn_ui:
			respawn_ui.visible = true
			print("[MINIGAME_MANAGER] Found RespawnUI on second attempt")
			# Also hide guide instructions
			if guide_instructions_label:
				guide_instructions_label.visible = false

# Function to reset the game state
func reset_game():
	current_health = max_health
	game_active = true
	player_invulnerable = false
	
	if hearts_container:
		hearts_container.update_hearts(current_health)
	
	# Re-enable boss if needed
	var boss = get_tree().get_root().find_child("BossSnake", true, false)
	if boss:
		boss.set_process(true)
		boss.set_physics_process(true)
		
		# Restart timers
		var timers = [
			boss.get_node_or_null("SmallProjectileTimer"),
			boss.get_node_or_null("MediumProjectileTimer"),
			boss.get_node_or_null("LargeProjectileTimer"),
			boss.get_node_or_null("StateTimer")
		]
		for timer in timers:
			if timer:
				timer.start()
				
	# Make sure player is visible (not mid-flash)
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.visible = true
		
	# Hide respawn UI and show guide instructions
	if respawn_ui:
		respawn_ui.visible = false
	
	if guide_instructions_label:
		guide_instructions_label.visible = true
		print("[MINIGAME_MANAGER] GuideInstructionsLabel shown after game reset")

# Handle visibility changes of the respawn UI
func _on_respawn_ui_visibility_changed():
	if respawn_ui and guide_instructions_label:
		# If respawn UI is visible, hide guide instructions
		if respawn_ui.visible:
			guide_instructions_label.visible = false
			print("[MINIGAME_MANAGER] GuideInstructionsLabel hidden due to respawn UI visibility change")
		else:
			# Only show guide instructions if terminal UI is not visible
			var terminal_ui = get_tree().get_root().find_child("RocketTerminalUI", true, false)
			if terminal_ui and terminal_ui.visible:
				# Don't show guide instructions if terminal is open
				print("[MINIGAME_MANAGER] Keeping GuideInstructionsLabel hidden because terminal UI is visible")
			else:
				guide_instructions_label.visible = true
				print("[MINIGAME_MANAGER] GuideInstructionsLabel shown due to respawn UI visibility change")

# Function to handle minigame completion
func on_minigame_completed():
	print("[MINIGAME_MANAGER] on_minigame_completed called!")

	print("[MINIGAME_MANAGER] Transitioning to scene: ", next_scene)

	# Make sure to unpause
	get_tree().paused = false

	# Direct scene change approach for reliability
	print("[MINIGAME_MANAGER] Using change_scene_to_file with path: ", next_scene)
	var result = get_tree().change_scene_to_file(next_scene)

	# Check for errors
	if result != OK:
		print("[MINIGAME_MANAGER] ERROR: Failed to change scene! Error code: ", result)
		print("[MINIGAME_MANAGER] Attempting alternative scene change...")
		# Try hardcoded path as fallback
		get_tree().change_scene_to_file("res://Minigame Scenes and Scripts/Chapter 1/chapter_1_world_part_4.tscn") # Or whatever your next_scene is
	else:
		print("[MINIGAME_MANAGER] Scene change initiated successfully")
