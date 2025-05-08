#chapter_1_world_part_3.1.gd
extends Node2D

# References to nodes
@onready var player = $Player
@onready var idle_snake2 = $IdleSnake2
@onready var interaction_dialogue5 = $UILayer/InteractionDialogue5
@onready var player_camera = $Player/Camera2D if $Player else null

# Snake movement properties
var snake_initial_position = Vector2(4378.0, -124.0)
var snake_target_position = Vector2(4378.0, 27.0)
var snake_move_speed = 50.0
var snake_moving = false
var snake_destination_reached = false
var dialogue_started = false
var cutscene_in_progress = false

func _ready():
	# Ensure player movement is disabled during cutscene
	if player:
		if "can_move" in player:
			player.can_move = false
		else:
			player.set_process_input(false)
			player.set_physics_process(false)
		print("[SCENE] Player movement disabled")
	
	# Check if we have the snake
	if not idle_snake2:
		push_error("IdleSnake2 not found in the scene!")
		return
	
	# Set up snake initial position
	idle_snake2.position = snake_initial_position
	
	# Add cameras to a group for easier management
	if player and player.has_node("Camera2D"):
		player.get_node("Camera2D").add_to_group("cameras")
	
	if idle_snake2 and idle_snake2.has_node("Camera2D"):
		idle_snake2.get_node("Camera2D").add_to_group("cameras")
		# Make sure snake camera is disabled initially
		idle_snake2.get_node("Camera2D").enabled = false
	
	# Make sure dialogue is hidden initially
	if interaction_dialogue5:
		interaction_dialogue5.visible = false
		interaction_dialogue5.connect("dialogue_finished", Callable(self, "_on_interaction_dialogue_finished"))
	else:
		push_error("InteractionDialogue5 not found!")
	
	# Start the cutscene sequence after a short delay
	get_tree().create_timer(0.5).timeout.connect(func(): focus_camera_on_snake())

func _process(delta):
	# Handle snake movement
	if snake_moving and not snake_destination_reached:
		move_snake_towards_target(delta)
		
		# Check if snake reached target position
		if idle_snake2.position.distance_to(snake_target_position) < 5:
			snake_destination_reached = true
			snake_moving = false
			print("[SCENE] Snake reached destination")
			
			# Show dialogue after a short delay when snake reaches destination
			if not dialogue_started:
				dialogue_started = true
				get_tree().create_timer(0.5).timeout.connect(func(): start_dialogue())

func focus_camera_on_snake():
	print("[SCENE] Focusing camera on snake")
	cutscene_in_progress = true
	
	if idle_snake2:
		# Disable player camera if it exists
		if player and player.has_node("Camera2D"):
			player.get_node("Camera2D").enabled = false
		
		# Make sure any other cameras are disabled
		for camera in get_tree().get_nodes_in_group("cameras"):
			if camera != idle_snake2.get_node("Camera2D"):
				camera.enabled = false
		
		# Enable the snake camera
		idle_snake2.focus_camera()
		print("[SCENE] Snake camera activated")
		
		# Start snake movement after a short delay
		get_tree().create_timer(1.0).timeout.connect(func(): start_snake_movement())
	else:
		push_error("IdleSnake2 not found!")

func start_snake_movement():
	print("[SCENE] Starting snake movement from", snake_initial_position, "to", snake_target_position)
	snake_moving = true
	
	# Play walking animation on the snake
	if idle_snake2:
		idle_snake2.play_walking_animation()

func move_snake_towards_target(delta):
	# Calculate direction and velocity
	var direction = (snake_target_position - idle_snake2.position).normalized()
	var velocity = direction * snake_move_speed
	
	# Apply movement
	idle_snake2.position += velocity * delta

func start_dialogue():
	print("[SCENE] Starting dialogue sequence")
	
	# Set snake to idle animation
	if idle_snake2:
		idle_snake2.play_idle_animation()
	
	# Show dialogue
	if interaction_dialogue5:
		interaction_dialogue5.visible = true
	else:
		push_error("Cannot start dialogue - InteractionDialogue5 not found!")

func _on_interaction_dialogue_finished():
	print("[SCENE] Dialogue finished, transitioning to next scene")
	
	# Re-enable player movement (though it won't matter since we're changing scenes)
	if player:
		if "can_move" in player:
			player.can_move = true
		else:
			player.set_process_input(true)
			player.set_physics_process(true)
		print("[SCENE] Player movement re-enabled")
	
	# Here you would typically go to your next scene or start your mini game
	get_tree().change_scene_to_file("res://scenes/Levels/Chapter 1/chapter_1_world_part_3_2nd_minigame.tscn")
