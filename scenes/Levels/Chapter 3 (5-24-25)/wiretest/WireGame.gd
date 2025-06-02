extends Control

@onready var left_container = $LeftContainer
@onready var right_container = $RightContainer
@onready var wires = $Wires
@onready var restart_button = $RestartButton
@onready var feedback_label = $FeedbackLabel
@onready var todo_list = $TodoList

# NEW: Panel and Label for completion message
@onready var completion_panel = $CompletionPanel
@onready var completion_label = $CompletionPanel/CompletionLabel

var dragging = false
var start_button : Button = null
var start_position : Vector2
var temp_line_end : Vector2

var trivia_list = [
	"💡 Trivia: Plants rely on clean water and minerals from soil.",
	"💡 Trivia: Mining provides essential materials for filtration systems.",
	"💡 Trivia: Clean water supports both agriculture and daily life!"
]

# Define the correct connections (one-to-many)
var correct_matches = {
	"LeftButton1": ["RightButton2", "RightButton3"],
	"LeftButton2": ["RightButton1"],
	"LeftButton3": ["RightButton2"]
}

# Track connections
var connected_lines = []
# Track which connections have been made for each left button
var left_button_connections = {
	"LeftButton1": [],
	"LeftButton2": [],
	"LeftButton3": []
}

var game_completed = false

# Define a signal for game completion
signal wire_game_completed

func _ready():
	randomize()
	restart_button.visible = false
	restart_button.pressed.connect(on_restart_pressed)
	
	# Hide the completion panel at the start
	completion_panel.visible = false

	for button in left_container.get_children():
		button.pressed.connect(on_left_button_pressed.bind(button))
	
	for button in right_container.get_children():
		button.pressed.connect(on_right_button_pressed.bind(button))
	
	# Initialize the TodoList
	update_todo_list()

func update_todo_list():
	var todo_text = "To Do List:\n"
	for left_button_name in correct_matches:
		var targets = correct_matches[left_button_name]
		for target in targets:
			var left_display = left_button_name.replace("LeftButton", "L")
			var right_display = target.replace("RightButton", "R")
			
			# Check if this connection has been made
			var is_connected = false
			if left_button_name in left_button_connections:
				if target in left_button_connections[left_button_name]:
					is_connected = true
			
			# Add checkmark for completed connections
			if is_connected:
				todo_text += "✅ "
			else:
				todo_text += "⬜ "
			
			todo_text += left_display + " → " + right_display + "\n"
	
	todo_list.text = todo_text

func on_left_button_pressed(button):
	if game_completed:
		return
		
	dragging = true
	start_button = button
	start_position = button.get_global_position() + button.size / 2

func on_right_button_pressed(button):
	if game_completed:
		return
		
	if dragging and start_button:
		var end_position = button.get_global_position() + button.size / 2
		
		# Prevent duplicate connections
		for conn in connected_lines:
			if conn["start_button"] == start_button and conn["end_button"] == button:
				dragging = false
				start_button = null
				return
		
		# Add this connection to our tracking
		connected_lines.append({
			"start": start_position,
			"end": end_position,
			"start_button": start_button,
			"end_button": button,
			"is_correct": null
		})
		
		# Track which connections have been made for each left button
		left_button_connections[start_button.name].append(button.name)
		
		wires.queue_redraw()
		
		# Update todo list to show progress
		update_todo_list()
		
		dragging = false
		start_button = null
		
		# Check if all required connections have been made
		check_all_connections()

func _input(event):
	if game_completed:
		return
		
	if dragging and event is InputEventMouseMotion:
		temp_line_end = event.position
		wires.queue_redraw()

func check_all_connections():
	# Count how many total connections we need
	var total_required_connections = 0
	for targets in correct_matches.values():
		total_required_connections += targets.size()
	
	# Count how many connections we have
	var total_connections = connected_lines.size()
	
	# Check if all left buttons have made all their required connections
	var all_connections_complete = true
	for left_button_name in correct_matches:
		var required_connections = correct_matches[left_button_name]
		var made_connections = left_button_connections[left_button_name]
		
		# Check if this left button has all its required connections
		var has_all_required = true
		for required in required_connections:
			if not required in made_connections:
				has_all_required = false
				break
		
		if not has_all_required:
			all_connections_complete = false
			break
	
	# If we've made all necessary connections or have more than needed, validate
	if all_connections_complete or total_connections >= total_required_connections:
		validate_connections()

func validate_connections():
	var all_correct = true
	var feedback_text = ""
	
	# First pass - mark connections as correct or incorrect
	for conn in connected_lines:
		var start_button = conn["start_button"]
		var end_button = conn["end_button"]
		var correct_targets = correct_matches.get(start_button.name, [])
		
		if end_button.name in correct_targets:
			conn["is_correct"] = true
		else:
			conn["is_correct"] = false
			all_correct = false
			feedback_text += "❌ " + start_button.name + " should not connect to " + end_button.name + "\n"
	
	# Second pass - check if all required connections are made
	for left_button_name in correct_matches:
		var required_connections = correct_matches[left_button_name]
		var made_connections = left_button_connections[left_button_name]
		
		for required in required_connections:
			if not required in made_connections:
				all_correct = false
				feedback_text += "❌ " + left_button_name + " needs to connect to " + required + "\n"
	
	if not all_correct:
		restart_button.show()
		feedback_label.text = feedback_text
		feedback_label.visible = true
		# Hide the completion panel if showing
		completion_panel.visible = false
	else:
		restart_button.hide()
		feedback_label.text = "✅ All connections are correct!"
		feedback_label.visible = true

		# SHOW COMPLETION PANEL
		completion_label.text = "🎉 You finished the wire minigame!"
		completion_panel.visible = true

		# Set game as completed
		game_completed = true
		disable_all_buttons()
		emit_signal("wire_game_completed")
	
	wires.queue_redraw()

func on_restart_pressed():
	reset_game()

func disable_all_buttons():
	# Disable all buttons to prevent further connections
	for button in left_container.get_children():
		button.disabled = true
	for button in right_container.get_children():
		button.disabled = true

func reset_game():
	connected_lines.clear()
	dragging = false
	start_button = null
	restart_button.visible = false
	feedback_label.text = ""
	feedback_label.visible = false

	# Hide completion panel when restarting
	completion_panel.visible = false

	# Reset game completed state
	game_completed = false
	
	# Reset connections tracking
	for left_button_name in left_button_connections:
		left_button_connections[left_button_name] = []
	
	for button in left_container.get_children():
		button.disabled = false
	for button in right_container.get_children():
		button.disabled = false
	
	# Update the todo list to show all tasks unchecked
	update_todo_list()
	
	wires.queue_redraw()

func _draw():
	pass
