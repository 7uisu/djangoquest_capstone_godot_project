#idle_snake.gd
extends CharacterBody2D
# Snake movement properties
@export var move_speed = 50.0
@export var target_position = Vector2(623, -133)
var initial_position = Vector2(623, -326)
var is_moving = false
var destination_reached = false
@onready var chasing_snake = get_node("/root/Main/Playground/ChasingSnake")
 # Adjust this path to where your ChasingSnake node is


# References to components
@onready var animated_sprite = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer
@onready var snake_camera = $Camera2D

# Dialogue references
var interaction_dialogue_scene = preload("res://scenes/Levels/Chapter 1/interaction_dialogue_2.tscn")
var interaction_dialogue_3_scene = preload("res://scenes/Levels/Chapter 1/interaction_dialogue_3.tscn")
var dialogue_active = false
var current_dialogue = 0  # 0 = none, 1 = dialogue 2, 2 = dialogue 3

# Camera transition
var camera_focused = false
var camera_transition_time = 1.0
var camera_transition_timer = 0.0
var scene_change_pending = false

func _ready():
	position = initial_position
	play_idle_animation()
	is_moving = false
	add_to_group("idle_snake")
	process_mode = Node.PROCESS_MODE_ALWAYS
	print("[SNAKE] Initialized at position: ", position)

func _process(delta):
	if camera_focused and camera_transition_timer < camera_transition_time:
		camera_transition_timer += delta
		if camera_transition_timer >= camera_transition_time:
			start_movement()
	
	if is_moving and not destination_reached:
		move_towards_target(delta)
		if position.distance_to(target_position) < 5:
			destination_reached = true
			is_moving = false
			play_idle_animation()
			print("[SNAKE] Reached destination, showing dialogue in 0.5 seconds")
			await get_tree().create_timer(0.5).timeout
			show_dialogue()

			# Move Camera2D to y = 59 after reaching destination
			if snake_camera:
				snake_camera.position.y = 59
				print("[SNAKE] Camera moved to y = 59")


# Find the player node using all possible methods
func find_player():
	var player = null
	
	# Method 1: Try groups
	player = get_tree().get_first_node_in_group("player")
	if player:
		print("[SNAKE] Found player via group: ", player.name)
		return player
		
	# Method 2: Try fixed paths
	player = get_node_or_null("/root/playground/Player")
	if player:
		print("[SNAKE] Found player via direct path: ", player.name)
		return player
		
	# Method 3: Try scene traversal
	var root = get_tree().get_root()
	for child in root.get_children():
		# Print all root nodes to help debugging
		print("[SNAKE DEBUG] Root node: ", child.name)
		# Look for a node named Player or player
		var potential_player = child.find_child("Player", true, false)
		if potential_player:
			print("[SNAKE] Found player via tree search: ", potential_player.name)
			return potential_player
	
	# Method 4: Try get_nodes_in_group
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		print("[SNAKE] Found player via get_nodes_in_group: ", players[0].name)
		return players[0]
	
	print("[SNAKE ERROR] Could not find player by any method!")
	return null

func find_player_camera(player):
	var camera = null
	
	# Skip if no player
	if not player:
		return null
		
	# Method 1: Direct child
	camera = player.get_node_or_null("Camera2D")
	if camera:
		print("[SNAKE] Found camera as direct child of player")
		return camera
		
	# Method 2: Find in player's children
	camera = player.find_child("Camera2D", true, false)
	if camera:
		print("[SNAKE] Found camera in player's hierarchy")
		return camera
		
	# Method 3: Direct path
	camera = get_node_or_null("/root/playground/Player/Camera2D")
	if camera:
		print("[SNAKE] Found camera via direct path")
		return camera
		
	# Method 4: Find in scene
	camera = get_tree().get_root().find_child("Camera2D", true, false)
	if camera:
		print("[SNAKE] Found camera in scene hierarchy")
		return camera
	
	print("[SNAKE ERROR] Could not find player camera by any method!")
	return null

func focus_camera():
	print("[SNAKE] Attempting to focus camera")
	camera_focused = true
	camera_transition_timer = 0.0
	
	# Find player
	var player = find_player()
	
	# Switch camera to snake
	if snake_camera:
		print("[SNAKE] Switching to snake camera")
		snake_camera.make_current()
	else:
		print("[SNAKE ERROR] No snake camera found!")
	
	# Freeze player movement - handle in multiple ways
	if player:
		print("[SNAKE] Player found, attempting to disable movement via: ", player.name)
		
		# Print available properties and methods for debugging
		print("[SNAKE DEBUG] Player properties: ", player.get_property_list())
		
		# Try direct property access first
		if "can_move" in player:
			player.can_move = false
			print("[SNAKE] Player movement disabled via can_move property")
		# Try calling a method
		elif player.has_method("set_can_move"):
			player.set_can_move(false)
			print("[SNAKE] Player movement disabled via set_can_move method")
		# Try movement properties
		elif "movement_enabled" in player:
			player.movement_enabled = false
			print("[SNAKE] Player movement disabled via movement_enabled property")
		# Try pausing the player
		else:
			player.process_mode = Node.PROCESS_MODE_DISABLED
			print("[SNAKE] Player disabled via process_mode")
	else:
		print("[SNAKE ERROR] Cannot disable player movement - no player found!")
	
	print("[SNAKE] Camera focused on IdleSnake")

func start_movement():
	is_moving = true
	play_walking_animation()
	print("[SNAKE] Starting movement from ", position, " to ", target_position)

func move_towards_target(delta):
	var direction = (target_position - position).normalized()
	velocity = direction * move_speed
	move_and_slide()

func play_idle_animation():
	animated_sprite.play("default")

func play_walking_animation():
	if animated_sprite.sprite_frames.has_animation("walking"):
		animated_sprite.play("walking")
	else:
		animated_sprite.play("default")

func show_dialogue():
	if dialogue_active:
		print("[SNAKE] Dialogue already active, ignoring")
		return
		
	print("[SNAKE] Showing dialogue")
	dialogue_active = true
	current_dialogue = 1  # Set to first dialogue (interaction_dialogue_2)
	
	# Find player again
	var player = find_player()
	
	# Double-check player movement is disabled
	if player:
		# Try all possible ways to disable movement
		if "can_move" in player:
			player.can_move = false
			print("[SNAKE] Player movement disabled for dialogue via can_move")
		elif player.has_method("set_can_move"):
			player.set_can_move(false)
			print("[SNAKE] Player movement disabled for dialogue via method")
		elif "movement_enabled" in player:
			player.movement_enabled = false
			print("[SNAKE] Player movement disabled via movement_enabled property")
		else:
			player.process_mode = Node.PROCESS_MODE_DISABLED
			print("[SNAKE] Player disabled via process_mode")
	
	# Find UI layer
	var ui_layer = get_tree().get_root().get_node_or_null("playground/UILayer")
	if not ui_layer:
		ui_layer = get_tree().get_root().find_child("UILayer", true, false)
	
	if not ui_layer:
		print("[SNAKE ERROR] UILayer not found!")
		# Create temporary UI layer
		ui_layer = Control.new()
		ui_layer.name = "TempUILayer"
		get_tree().get_root().add_child(ui_layer)
		print("[SNAKE] Created temporary UI layer")
	else:
		print("[SNAKE] Found UI layer: ", ui_layer.name)
	
	# Clean up existing dialogues
	for child in ui_layer.get_children():
		if child.name == "InteractionDialogue" or child.is_in_group("dialogue"):
			child.queue_free()
	
	# Create dialogue instance
	var dialogue_instance = interaction_dialogue_scene.instantiate()
	dialogue_instance.name = "InteractionDialogue"
	dialogue_instance.add_to_group("dialogue")
	ui_layer.add_child(dialogue_instance)
	
	# Connect signal with error checking
	if dialogue_instance.has_signal("dialogue_finished"):
		var result = dialogue_instance.connect("dialogue_finished", _on_dialogue_finished)
		if result == OK:
			print("[SNAKE] Successfully connected dialogue_finished signal")
		else:
			print("[SNAKE ERROR] Failed to connect dialogue_finished signal! Error: ", result)
	else:
		print("[SNAKE ERROR] Dialogue doesn't have 'dialogue_finished' signal!")
		# Try to add a deferred call as a fallback
		get_tree().create_timer(10.0).timeout.connect(_on_dialogue_finished)
		print("[SNAKE] Added fallback timer for dialogue")
	
	# Start the dialogue
	if dialogue_instance.has_method("start_dialogue"):
		dialogue_instance.start_dialogue("snake_introduction")
		print("[SNAKE] Snake dialogue started")
	else:
		print("[SNAKE ERROR] Dialogue doesn't have start_dialogue method!")

# Function to show the third dialogue
func show_dialogue_3():
	if dialogue_active:
		print("[SNAKE] Dialogue already active, ignoring")
		return
		
	print("[SNAKE] Showing dialogue 3")
	dialogue_active = true
	current_dialogue = 2  # Set to second dialogue (interaction_dialogue_3)
	
	# Find UI layer
	var ui_layer = get_tree().get_root().get_node_or_null("playground/UILayer")
	if not ui_layer:
		ui_layer = get_tree().get_root().find_child("UILayer", true, false)
	
	if not ui_layer:
		print("[SNAKE ERROR] UILayer not found for dialogue 3!")
		# Create temporary UI layer
		ui_layer = Control.new()
		ui_layer.name = "TempUILayer"
		get_tree().get_root().add_child(ui_layer)
		print("[SNAKE] Created temporary UI layer for dialogue 3")
	else:
		print("[SNAKE] Found UI layer for dialogue 3: ", ui_layer.name)
	
	# Clean up existing dialogues
	for child in ui_layer.get_children():
		if child.name == "InteractionDialogue" or child.is_in_group("dialogue"):
			child.queue_free()
	
	# Create dialogue instance
	var dialogue_instance = interaction_dialogue_3_scene.instantiate()
	dialogue_instance.name = "InteractionDialogue3"
	dialogue_instance.add_to_group("dialogue")
	ui_layer.add_child(dialogue_instance)
	
	# Connect signal with error checking
	if dialogue_instance.has_signal("dialogue_finished"):
		var result = dialogue_instance.connect("dialogue_finished", _on_dialogue_finished)
		if result == OK:
			print("[SNAKE] Successfully connected dialogue_finished signal for dialogue 3")
		else:
			print("[SNAKE ERROR] Failed to connect dialogue_finished signal for dialogue 3! Error: ", result)
	else:
		print("[SNAKE ERROR] Dialogue 3 doesn't have 'dialogue_finished' signal!")
		# Try to add a deferred call as a fallback
		get_tree().create_timer(10.0).timeout.connect(_on_dialogue_finished)
		print("[SNAKE] Added fallback timer for dialogue 3")
	
	# Start the dialogue
	if dialogue_instance.has_method("start_dialogue"):
		dialogue_instance.start_dialogue("snake_continuation")
		print("[SNAKE] Snake dialogue 3 started")
	else:
		print("[SNAKE ERROR] Dialogue 3 doesn't have start_dialogue method!")

# Callback for when dialogue finishes
func _on_dialogue_finished():
	print("[SNAKE] Dialogue finished callback triggered! Current dialogue: ", current_dialogue)
	dialogue_active = false
	
	# Check which dialogue just finished
	if current_dialogue == 1:
		# First dialogue finished, now show the second one
		print("[SNAKE] First dialogue finished, starting dialogue 3")
		await get_tree().create_timer(0.5).timeout
		show_dialogue_3()
		return
	elif current_dialogue == 2:
		# Second dialogue finished, now return to player and start chase sequence
		print("[SNAKE] All dialogues finished, returning control to player and starting chase")
		current_dialogue = 0
	
	# Find player and camera again
	var player = find_player()
	var player_camera = find_player_camera(player)
	
	# Clean up dialogues
	var ui_layer = get_tree().get_root().get_node_or_null("playground/UILayer")
	if ui_layer:
		for child in ui_layer.get_children():
			if child.name == "InteractionDialogue" or child.name == "InteractionDialogue3" or child.is_in_group("dialogue"):
				child.queue_free()
	
	# Switch camera back to player
	if player_camera:
		print("[SNAKE] Switching camera back to player")
		player_camera.make_current()
		
		# Show Guide1Label and Guide2Label when returning to gameplay
		var guide1_label = player_camera.get_node_or_null("Guide1Label")
		var guide2_label = player_camera.get_node_or_null("Guide2Label")
		
		if guide1_label:
			guide1_label.visible = true
			print("[SNAKE] Guide1Label made visible")
		else:
			print("[SNAKE WARNING] Guide1Label not found in player camera")
			
		if guide2_label:
			guide2_label.visible = true
			print("[SNAKE] Guide2Label made visible")
		else:
			print("[SNAKE WARNING] Guide2Label not found in player camera")
	else:
		print("[SNAKE ERROR] Cannot switch camera - no player camera reference!")
	
	# Re-enable player movement
	if player:
		print("[SNAKE] Attempting to re-enable player movement")
		if "can_move" in player:
			player.can_move = true
			print("[SNAKE] Player movement re-enabled via property")
		elif player.has_method("set_can_move"):
			player.set_can_move(true)
			print("[SNAKE] Player movement re-enabled via method")
		elif "movement_enabled" in player:
			player.movement_enabled = true
			print("[SNAKE] Player movement re-enabled via movement_enabled property")
		else:
			player.process_mode = Node.PROCESS_MODE_INHERIT
			print("[SNAKE] Player re-enabled via process_mode")
	else:
		print("[SNAKE ERROR] Cannot re-enable player movement - no player reference!")
	
	# Resume game if paused
	get_tree().paused = false
	
	# Hide the idle snake (this node)
	visible = false
	
	# Activate the chasing snake
	if chasing_snake:
		print("[SNAKE] Activating chasing snake!")
		if chasing_snake.has_method("activate"):
			chasing_snake.activate()
		else:
			print("[SNAKE ERROR] ChasingSnake doesn't have activate method!")
	else:
		# Try finding the snake in the scene as fallback
		var fallback_snake = get_tree().get_root().find_child("ChasingSnake", true, false)
		if fallback_snake and fallback_snake.has_method("activate"):
			print("[SNAKE] Activating fallback chasing snake!")
			fallback_snake.activate()
		else:
			print("[SNAKE ERROR] Could not find or activate ChasingSnake node!")
		
	# Re-enable player movement again (just to be safe)
	if player:
		if "can_move" in player:
			player.can_move = true
			print("[SNAKE] Player movement re-enabled via can_move")
		elif player.has_method("set_can_move"):
			player.set_can_move(true)
			print("[SNAKE] Player movement re-enabled via set_can_move method")
		elif "movement_enabled" in player:
			player.movement_enabled = true
			print("[SNAKE] Player movement re-enabled via movement_enabled property")
		else:
			player.process_mode = Node.PROCESS_MODE_INHERIT
			print("[SNAKE] Player process_mode set back to INHERIT")

	# Reset dialogue state
	dialogue_active = false
	current_dialogue = 0
	print("[SNAKE] Dialogue state reset, control fully returned to player")
