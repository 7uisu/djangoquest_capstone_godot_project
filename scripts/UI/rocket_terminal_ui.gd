# rocket_terminal_ui.gd
extends Control

@onready var instruction_label = $InstructionLabel
@onready var boss_state_label = $BossSnakeStateLabel
@onready var line_edit = $LineEdit
@onready var enter_button = $EnterButton
@onready var boss_snake_preview = $BossSnakePreview  # Preview AnimatedSprite

# Reference to the boss snake for state tracking
var boss_snake = null
# Reference to guide instructions label
var guide_instructions_label = null
# Reference to respawn UI
var respawn_ui = null

# State descriptions for player understanding
var state_descriptions = {
	0: "ATTACK - DANGER! Snake is attacking!",
	1: "REST - Safe to operate terminal",
	2: "WINDUP - Snake preparing to attack soon..."
}

# Update interval for boss state
var update_timer = null
var update_interval = 0.5 # Check every half second

# Tutorial variables
var current_step = 0
var steps = [
	"Creating a Virtual Environment",
	"Activating the Environment",
	"Installing Django",
	"Creating a Django Project",
	"Navigating to Project Directory"
]

# Store user's environment and project names
var environment_name = ""
var project_name = ""

# Flag to handle first input after opening terminal
var first_focus = true
# Flag to prevent multiple focus reset events
var focus_handled = false

func _ready():
	# Make UI hidden at start
	visible = false
	
	# Find boss snake
	boss_snake = get_tree().get_root().find_child("BossSnake", true, false)
	if boss_snake:
		print("[TERMINAL_UI] Found BossSnake reference")
	else:
		print("[TERMINAL_UI] ERROR: Could not find BossSnake")
	
	# Find guide instructions label
	guide_instructions_label = get_node_or_null("/root/chapter_1_world_part_3_2nd_minigame/MinigameManager/UILayer/GuideInstructionsLabel")
	if not guide_instructions_label:
		guide_instructions_label = get_tree().get_root().find_child("GuideInstructionsLabel", true, false)
	if guide_instructions_label:
		print("[TERMINAL_UI] Found GuideInstructionsLabel reference")
	else:
		print("[TERMINAL_UI] WARNING: Could not find GuideInstructionsLabel")
	
	# Find respawn UI
	respawn_ui = get_node_or_null("/root/chapter_1_world_part_3_2nd_minigame/MinigameManager/UILayer/RespawnUIWorld1Minigame2")
	if not respawn_ui:
		respawn_ui = get_tree().get_root().find_child("RespawnUIWorld1Minigame2", true, false)
		if not respawn_ui:
			respawn_ui = get_tree().get_root().find_child("RespawnUI", true, false)
	if respawn_ui:
		print("[TERMINAL_UI] Found RespawnUI reference")
	else:
		print("[TERMINAL_UI] WARNING: Could not find RespawnUI")
	
	# Set up timer for state updates
	update_timer = Timer.new()
	update_timer.wait_time = update_interval
	update_timer.autostart = false
	update_timer.one_shot = false
	add_child(update_timer)
	update_timer.timeout.connect(_on_update_timer_timeout)
	
	# Connect UI signals
	if enter_button:
		enter_button.pressed.connect(_on_enter_button_pressed)
	else:
		print("[TERMINAL_UI] WARNING: Enter button not found")
	
	# Set initial instruction text
	if instruction_label:
		_update_instruction_for_current_step()
	else:
		print("[TERMINAL_UI] WARNING: Instruction label not found")
	
	# Connect visibility change signal
	visibility_changed.connect(_on_visibility_changed)
	
	# Connect LineEdit action signals
	if line_edit:
		line_edit.text_submitted.connect(_on_line_edit_text_submitted)
		# Connect to focus entered to clear first input
		line_edit.focus_entered.connect(_on_line_edit_focus_entered)

func _process(_delta):
	# Check for ESC to close the terminal
	if visible and Input.is_action_just_pressed("ui_cancel"):
		_hide_terminal_ui()
		print("[TERMINAL_UI] Terminal closed via ESC")

# Update the boss state label and animation preview
func update_boss_state():
	if not boss_snake:
		# Try to find boss again
		boss_snake = get_tree().get_root().find_child("BossSnake", true, false)
		if not boss_snake:
			if boss_state_label:
				boss_state_label.text = "Boss State: UNKNOWN\nCould not find boss reference"
				boss_state_label.modulate = Color(1, 1, 1) # White
			return
	
	if boss_state_label:
		var current_state = boss_snake.current_state
		var state_name = "UNKNOWN"
		var state_desc = "Could not determine state"
		
		# Get state name from enum if possible
		if current_state >= 0 and current_state < boss_snake.State.size():
			state_name = boss_snake.State.keys()[current_state]
			state_desc = state_descriptions.get(current_state, "No description")
		
		# Update label
		boss_state_label.text = "Boss State: " + state_name + "\n" + state_desc
		
		# Update preview animation to match boss animation
		update_snake_preview(current_state)
		
		# Set color based on state
		match current_state:
			0: # Attack - red
				boss_state_label.modulate = Color(1, 0.3, 0.3) # Red
			1: # Rest - green
				boss_state_label.modulate = Color(0.3, 1, 0.3) # Green
			2: # Windup - yellow
				boss_state_label.modulate = Color(1, 1, 0.3) # Yellow
			_: # Unknown - white
				boss_state_label.modulate = Color(1, 1, 1) # White
		
		# Reduced logging to prevent console spam
		# print("[TERMINAL_UI] Updated boss state to: ", state_name)
	else:
		print("[TERMINAL_UI] ERROR: Boss state label not found")

# Function to update the snake preview animation
func update_snake_preview(current_state):
	if not boss_snake_preview:
		return
		
	# Match the animation to the current state
	match current_state:
		0: # ATTACK
			if boss_snake_preview.sprite_frames.has_animation("attack"):
				boss_snake_preview.play("attack")
		1: # REST
			if boss_snake_preview.sprite_frames.has_animation("rest"):
				boss_snake_preview.play("rest")
		2: # WINDUP
			if boss_snake_preview.sprite_frames.has_animation("windup"):
				boss_snake_preview.play("windup")
		_: # Default/Unknown
			if boss_snake_preview.sprite_frames.has_animation("default"):
				boss_snake_preview.play("default")
			elif boss_snake_preview.sprite_frames.has_animation("rest"):
				boss_snake_preview.play("rest")

# Timer callback to update the boss state display
func _on_update_timer_timeout():
	update_boss_state()

func _on_enter_button_pressed():
	if line_edit:
		var command = line_edit.text.strip_edges()
		check_command(command)
		line_edit.clear()
		line_edit.grab_focus()

# Handle LineEdit text submission (Enter key)
func _on_line_edit_text_submitted(text: String):
	check_command(text)
	line_edit.clear()

# Function to handle focus entered
func _on_line_edit_focus_entered():
	if first_focus and not focus_handled:
		# Clear the LineEdit to remove any interaction key (like 'f')
		line_edit.clear()
		first_focus = false
		focus_handled = true
		print("[TERMINAL_UI] First focus - cleared LineEdit")

# Hide the terminal UI
func _hide_terminal_ui():
	visible = false
	update_timer.stop() # Stop updates when not visible
	first_focus = true # Reset first focus flag
	focus_handled = false # Reset focus handled flag
	
	# Show guide instructions if they exist and respawn UI is not visible
	if guide_instructions_label:
		if respawn_ui and respawn_ui.visible:
			# Don't show guide instructions if respawn UI is visible
			print("[TERMINAL_UI] Keeping guide instructions hidden because respawn UI is visible")
		else:
			if guide_instructions_label.has_method("show"):
				guide_instructions_label.show()
			else:
				guide_instructions_label.visible = true
			print("[TERMINAL_UI] Terminal UI hidden, guide instructions shown")
	else:
		print("[TERMINAL_UI] WARNING: Could not find guide instructions to show")

# Update instruction label for current tutorial step
func _update_instruction_for_current_step():
	if not instruction_label:
		return
		
	if current_step < steps.size():
		instruction_label.text = steps[current_step]
		
		# Add hint for each step
		match current_step:
			0: # Creating Virtual Environment
				instruction_label.text += "\nHint: Use 'python -m venv (Environment Name)'"
			1: # Activating Environment
				instruction_label.text += "\nHint: Use '" + environment_name + "\n\\Scripts\\activate.bat'"
			2: # Installing Django
				instruction_label.text += "\nHint: Use 'python -m pip install django'"
			3: # Creating Django Project
				instruction_label.text += "\nHint: Use 'django-admin \nstartproject (Project Name)'"
			4: # Navigate to Project Directory
				instruction_label.text += "\nHint: Use 'cd " + project_name + "'"
	else:
		instruction_label.text = "Django setup complete! Press ESC to exit."

# Check if the command is correct for the current step
func check_command(command: String):
	print("[TERMINAL_UI] Checking command: ", command)
	
	if command == "":
		return
	
	match current_step:
		0: # Creating Virtual Environment
			if command.begins_with("python -m venv "):
				# Extract environment name
				environment_name = command.trim_prefix("python -m venv ").strip_edges()
				if environment_name == "":
					show_error("Please provide an environment name")
					return
				
				advance_step()
			else:
				show_error("Incorrect command. Try 'python -m venv (Environment Name)'")
				
		1: # Activating Environment
			# Allow either exact match with saved environment name or any activation command
			var expected_cmd = environment_name + "\\Scripts\\activate.bat"
			if command == expected_cmd or (command.ends_with("\\Scripts\\activate.bat") and command.begins_with(environment_name)):
				advance_step()
			else:
				show_error("Incorrect command. Try '" + environment_name + "\n\\Scripts\\activate.bat'")
				
		2: # Installing Django
			if command == "python -m pip install django":
				advance_step()
			else:
				show_error("Incorrect command. \nTry 'python -m pip install django'")
				
		3: # Creating Django Project
			if command.begins_with("django-admin startproject "):
				# Extract project name
				project_name = command.trim_prefix("django-admin startproject ").strip_edges()
				if project_name == "":
					show_error("Please provide a project name")
					return
					
				advance_step()
			else:
				show_error("Incorrect command. \nTry 'django-admin startproject (Project Name)'")
				
		4: # Navigate to Project Directory
			# Much more flexible check - accept any cd command to complete the tutorial
			if command.begins_with("cd "):
				# Update project name if different
				var cd_arg = command.trim_prefix("cd ").strip_edges()
				if cd_arg != "":
					project_name = cd_arg
					print("[TERMINAL_UI] Updated project name to: ", project_name)
				
				complete_tutorial()
			else:
				show_error("Incorrect command. Try 'cd " + project_name + "'")
				
		_: # No more steps
			instruction_label.text = "Tutorial completed! Press ESC to exit."

# Show error message
func show_error(message: String):
	if instruction_label:
		instruction_label.text = "ERROR: " + message + "\n\n" + steps[current_step]

# Advance to the next step
func advance_step():
	current_step += 1
	print("[TERMINAL_UI] Advanced to step: ", current_step)
	
	if current_step < steps.size():
		_update_instruction_for_current_step()
	else:
		complete_tutorial()

# Complete the tutorial
func complete_tutorial():
	current_step = steps.size()  # Ensure we're at the end
	instruction_label.text = "Django setup complete!\nYou've successfully set up a Django project.\nChanging scene now..."
	print("[ROCKET_TERMINAL] MINIGAME COMPLETED!")
	
	# CRITICAL: Don't pause the game - this might be preventing the timer from firing
	# get_tree().paused = true  <-- REMOVE THIS LINE
	print("[TERMINAL_UI] Executing direct scene change")
	
	# DIRECTLY change the scene without using timers
	print("[TERMINAL_UI] Changing to next scene directly")
	get_tree().change_scene_to_file("res://scenes/Levels/Chapter 1/chapter_1_world_part_4.tscn")

# Called when UI becomes visible or invisible
func _on_visibility_changed():
	if visible:
		# Reset focus handling variables
		first_focus = true
		focus_handled = false
		
		# Hide guide instructions if they exist
		if guide_instructions_label and guide_instructions_label.has_method("hide"):
			guide_instructions_label.hide()
		elif guide_instructions_label:
			guide_instructions_label.visible = false
		
		print("[TERMINAL_UI] Terminal UI shown, guide instructions hidden")
		
		# Start updating boss state
		update_boss_state() # Update immediately
		update_timer.start() # Start periodic updates
		
		# Set focus to line edit with delay to avoid capturing the interaction key
		if line_edit:
			# Wait a tiny bit before focusing to avoid capturing the "f" key
			var focus_timer = Timer.new()
			focus_timer.wait_time = 0.1  # Increased delay to 100ms
			focus_timer.one_shot = true
			add_child(focus_timer)
			focus_timer.timeout.connect(func():
				line_edit.grab_focus()
				print("[TERMINAL_UI] Terminal UI shown, focus set to line edit with delay")
			)
			focus_timer.start()
			
		# Update instructions based on current progress
		_update_instruction_for_current_step()
	else:
		# Stop updates when hidden
		update_timer.stop()
		print("[TERMINAL_UI] Terminal UI hidden, updates stopped")

# Legacy command execution system (keeping for reference)
func execute_command(command: String):
	print("[TERMINAL_UI] Executing command: ", command)
	
	# Command processing logic here
	if command == "exit" or command == "close" or command == "quit":
		_hide_terminal_ui()
	elif command == "help":
		if instruction_label:
			instruction_label.text = "Available commands:\n- exit/close/quit: Close terminal\n- help: Show this help\n- status: Show boss status\n- clear: Clear this display"
	elif command == "status":
		update_boss_state()
		if instruction_label:
			instruction_label.text = "Status updated. Monitor the boss state carefully."
	elif command == "clear":
		if instruction_label:
			instruction_label.text = "Terminal display cleared."
	else:
		check_command(command)

func find_node_in_scene(node_name):
	# First try direct search in the scene tree root
	var node = get_tree().get_root().find_child(node_name, true, false)
	if node:
		print("[TERMINAL_UI] Found node: ", node_name)
		return node
	
	# Try alternative search methods if needed
	var scene = get_tree().get_root()
	if scene:
		var nodes = scene.find_children("*", "", true, false)
		for n in nodes:
			if node_name in n.name:
				print("[TERMINAL_UI] Found node with partial name match: ", n.name)
				return n
	
	print("[TERMINAL_UI] ERROR: Could not find node: ", node_name)
	return null
