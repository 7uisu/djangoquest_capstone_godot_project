extends Area2D

@export var required_pages = 6
@export var next_scene_path = "res://scenes/NextLevel.tscn"
@export var debug_mode = true  # Enable debug logging

var message_shown = false

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

# Signal handler when any body enters the area
func _on_body_entered(body):
	debug_log("Body entered: " + body.name)
	
	# Check if it has the player methods
	if body.has_method("is_player"):
		debug_log("Player character detected")
		
		if body.has_method("get_collected_pages"):
			var pages = body.get_collected_pages()
			debug_log("Pages collected: " + str(pages) + "/" + str(required_pages))
			
			if pages >= required_pages:
				debug_log("SUCCESS! Player has all " + str(required_pages) + " pages! Loading next scene...")
				# Optional: You could add a message to the player here too
				if body.has_method("show_guide2_message"):
					body.show_guide2_message("All pages collected! Moving to next area...")
				# Wait a brief moment for the message to be visible
				await get_tree().create_timer(1.0).timeout
				get_tree().change_scene_to_file(next_scene_path)
			else:
				debug_log("Not enough pages, showing message to player")
				if body.has_method("show_guide2_message"):
					body.show_guide2_message("You need all 6 pages to continue!")
					message_shown = true
					# Reset message flag after delay
					await get_tree().create_timer(4.0).timeout
					message_shown = false
		else:
			debug_log("ERROR: Player doesn't have get_collected_pages method")
	else:
		debug_log("Body is not the player")

# Utility function for debug logging
func debug_log(message):
	if debug_mode:
		print("[CHASING_SNAKE_EXIT] " + message)
