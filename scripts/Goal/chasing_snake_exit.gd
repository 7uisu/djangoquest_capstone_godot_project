extends Area2D

@export var required_pages = 6
@export var next_scene_path = "res://scenes/Levels/Chapter 1/chapter_1_world_part_3.tscn"
@export var debug_mode = true  # Enable debug logging
var message_shown = false
var chasing_snakes = []  # Will store references to all chasing snakes in the scene

func _ready():
	# Debug print at startup
	debug_log("ChasingSnakeExit initialized")
	
	# Configure Area2D as a trigger
	monitoring = true      # Make sure Area2D is checking for bodies
	monitorable = false    # Not necessary for a trigger area
	collision_layer = 0    # Doesn't need to be on any layer since it's just detecting
	collision_mask = 1     # Mask includes layer 1 so it can detect the player
	
	# Connect the body entered signal
	body_entered.connect(_on_body_entered)
	debug_log("Signal connected")
	
	# Check for collision shape
	var has_shape = false
	for child in get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			has_shape = true
			debug_log("Found collision shape: " + child.name)
	
	if not has_shape:
		debug_log("WARNING: No collision shape found!")
	
	# Find all chasing snakes in the scene at startup
	call_deferred("find_chasing_snakes")

# Find all chasing snakes in the scene
func find_chasing_snakes():
	# Wait one frame to ensure the scene is fully loaded
	await get_tree().process_frame
	
	# Search for all nodes that might be chasing snakes
	var snake_nodes = get_tree().get_root().find_children("*ChasingSnake*", "CharacterBody2D", true, false)
	
	# Add any found snakes to our array
	for node in snake_nodes:
		if (node.has_method("activate") or "is_active" in node):
			chasing_snakes.append(node)
			debug_log("Found chasing snake: " + node.name)
	
	debug_log("Total chasing snakes found: " + str(chasing_snakes.size()))

# Signal handler when any body enters the area
func _on_body_entered(body):
	debug_log("Body entered: " + body.name)
	
	# Check if it has the player methods
	if body.has_method("is_player") or "Player" in body.name:
		debug_log("Player character detected")
		
		if body.has_method("get_collected_pages"):
			var pages = body.get_collected_pages()
			debug_log("Pages collected: " + str(pages) + "/" + str(required_pages))
			
			if pages >= required_pages:
				debug_log("SUCCESS! Player has all " + str(required_pages) + " pages!")
				
				# Disable all chasing snakes since player has all required pages
				disable_all_snakes()
				
				# Show success message
				if body.has_method("show_guide2_message"):
					body.show_guide2_message("All pages collected! The snake can't follow you anymore!")
				
				# Wait a brief moment for the message to be visible
				await get_tree().create_timer(2.0).timeout
				
				# Load next scene
				debug_log("Loading next scene...")
				get_tree().change_scene_to_file(next_scene_path)
			else:
				debug_log("Not enough pages, showing message to player")
				if body.has_method("show_guide2_message") and not message_shown:
					body.show_guide2_message("You need all 6 pages to continue!")
					message_shown = true
					# Reset message flag after delay
					await get_tree().create_timer(4.0).timeout
					message_shown = false
		else:
			debug_log("ERROR: Player doesn't have get_collected_pages method")
	else:
		debug_log("Body is not the player")

# Disable all chasing snakes in the scene
func disable_all_snakes():
	debug_log("Disabling all chasing snakes")
	for snake in chasing_snakes:
		if snake.has_method("deactivate"):
			snake.deactivate()
			debug_log("Deactivated snake: " + snake.name)
		else:
			# For snakes that don't have a deactivate method, use their is_active property
			if "is_active" in snake:
				snake.is_active = false
				debug_log("Set snake inactive: " + snake.name)
			else:
				debug_log("Could not deactivate snake: " + snake.name)

# Utility function for debugging
func debug_log(message):
	if debug_mode:
		print("[CHASING_SNAKE_EXIT] " + message)
