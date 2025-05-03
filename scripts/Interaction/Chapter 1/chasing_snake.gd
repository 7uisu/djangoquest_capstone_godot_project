#chasing_snake.gd
extends CharacterBody2D

# Chase properties
@export var chase_speed = 114.5  # Higher speed for more aggressive chase
@export var detection_radius = 1000.0  # Large radius to ensure detection
@export var min_distance = 10.0  # How close snake gets before considering position reached
var is_active = false
var player = null
var chase_offset = Vector2(0, 0)  # Offset to make snake chase slightly behind or ahead of player

# Debug mode
@export var debug_mode = true  # Set to true to show debug logs

# Path finding
var path = []
var path_index = 0
@export var use_pathfinding = false  # Set to true if using Navigation2D

# References to components
@onready var animated_sprite = $AnimatedSprite2D  # Make sure this exists in your scene
@onready var collision_shape = $CollisionShape2D  # Make sure this exists in your scene
@onready var detection_area = $DetectionArea  # Area2D for detecting player collision

# Called when the node enters the scene tree for the first time.
func _ready():
	is_active = false
	if animated_sprite and animated_sprite.has_method("play"):
		animated_sprite.play("default")  # Fallback to "default" if this doesn't exist
	
	# Disable collision initially
	if collision_shape:
		collision_shape.disabled = true
	
	# Connect the detection area signal
	if detection_area:
		detection_area.body_entered.connect(_on_detection_area_body_entered)
	
	debug_log("ChasingSnake initialized and waiting")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not is_active:
		return
	
	if player == null:
		find_player()
		if player == null:
			debug_log("Cannot chase - no player found!")
			return
	
	chase_player(delta)

func activate():
	debug_log("Activated and ready to chase")
	is_active = true
	
	# Enable collision
	if collision_shape:
		collision_shape.disabled = false
	
	# Find the player
	find_player()
	
	# Set chasing animation if available
	if animated_sprite:
		if animated_sprite.sprite_frames.has_animation("chasing"):
			animated_sprite.play("chasing")
		elif animated_sprite.sprite_frames.has_animation("walking"):
			animated_sprite.play("walking")
		elif animated_sprite.sprite_frames.has_animation("default"):
			animated_sprite.play("default")

# Find the player using multiple methods to be robust
func find_player():
	var potential_player = null
	
	# Method 1: Try groups
	potential_player = get_tree().get_first_node_in_group("player")
	if potential_player:
		player = potential_player
		debug_log("Found player via group")
		return
	
	# Method 2: Try direct path
	potential_player = get_node_or_null("/root/Main/Playground/Player")
	if not potential_player:
		potential_player = get_node_or_null("/root/playground/Player")
	
	if potential_player:
		player = potential_player
		debug_log("Found player via direct path")
		return
	
	# Method 3: Search through the scene tree
	var nodes = get_tree().get_root().find_children("Player*", "", true, false)
	if nodes.size() > 0:
		player = nodes[0]
		debug_log("Found player via tree search")
		return
	
	# Method 4: Last resort - find any CharacterBody2D
	nodes = get_tree().get_root().find_children("*", "CharacterBody2D", true, false)
	for node in nodes:
		if "Player" in node.name or node.is_in_group("player"):
			player = node
			debug_log("Found player via CharacterBody2D search")
			return
	
	debug_log("Player not found by any method!")

# Chase the player
func chase_player(delta):
	if not player:
		debug_log("No player to chase!")
		return
	
	# Get player position
	var player_pos = player.global_position + chase_offset
	
	# If using pathfinding
	if use_pathfinding and has_node("/root/Main/Navigation2D"):
		chase_with_pathfinding(player_pos, delta)
	else:
		# Direct chase
		chase_direct(player_pos, delta)

# Direct chase without pathfinding
func chase_direct(target_pos, delta):
	# Calculate direction to player
	var direction = (target_pos - global_position).normalized()
	
	# Set velocity
	velocity = direction * chase_speed
	
	# Determine sprite flip direction
	if animated_sprite:
		if direction.x < 0:
			animated_sprite.flip_h = true
		else:
			animated_sprite.flip_h = false
	
	# Apply movement
	move_and_slide()

# Chase with pathfinding if available
func chase_with_pathfinding(target_pos, delta):
	var nav_node = get_node_or_null("/root/Main/Navigation2D")
	if not nav_node:
		# Fallback to direct chase
		chase_direct(target_pos, delta)
		return
	
	# If we need to calculate a new path
	if path.size() == 0 or path_index >= path.size() or global_position.distance_to(target_pos) > 100:
		# Calculate path
		path = nav_node.get_simple_path(global_position, target_pos, true)
		path_index = 0
		
		if path.size() == 0:
			# Fallback to direct chase if no path found
			chase_direct(target_pos, delta)
			return
	
	# Follow path
	var next_point = path[path_index]
	var distance_to_next = global_position.distance_to(next_point)
	
	if distance_to_next < min_distance:
		path_index += 1
		if path_index >= path.size():
			# End of path, recalculate next frame
			return
		next_point = path[path_index]
	
	var direction = (next_point - global_position).normalized()
	velocity = direction * chase_speed
	move_and_slide()

# Handle collisions with player via the Area2D
func _on_detection_area_body_entered(body):
	debug_log("Body entered detection area: " + body.name)
	
	if not is_active:
		return
	
	# Check if it's the player using multiple methods
	if body == player or body.is_in_group("player") or body.has_method("is_player"):
		debug_log("Player caught!")
		handle_player_caught()

# Handle what happens when the player is caught
func handle_player_caught():
	# Try to find the respawn UI
	var respawn_ui = get_node_or_null("/root/Main/Playground/UILayer/RespawnUI")
	if not respawn_ui:
		respawn_ui = get_node_or_null("/root/playground/UILayer/RespawnUI")
	
	# Show the respawn UI if found
	if respawn_ui:
		debug_log("Found RespawnUI, showing it")
		if respawn_ui.has_method("show"):
			respawn_ui.show()
		else:
			respawn_ui.visible = true
	else:
		debug_log("RespawnUI not found, trying alternative methods")
		
	# Check if there's a game over handler in the scene
	var game_manager = get_node_or_null("/root/Main/GameManager")
	if game_manager and game_manager.has_method("player_caught"):
		game_manager.player_caught()
	else:
		# Fallback to direct game over
		if player.has_method("die"):
			player.die()
		elif player.has_method("game_over"):
			player.game_over()
		else:
			# Try to disable player movement
			if player.has_method("set_can_move"):
				player.set_can_move(false) 
			else:
				# Attempt to access can_move directly
				if "can_move" in player:
					player.can_move = false
			
			# Last resort: try to find and show the respawn UI
			var all_ui = get_tree().get_root().find_children("*RespawnUI*", "", true, false)
			if all_ui.size() > 0:
				all_ui[0].visible = true
			else:
				# Last last resort: try to reload the current scene
				get_tree().reload_current_scene()

# Utility function for consistent debug logging
func debug_log(message):
	if debug_mode:
		print("[CHASING_SNAKE] " + message)
		
