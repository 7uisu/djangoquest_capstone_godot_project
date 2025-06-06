extends Control
signal closed
@onready var line_edit = $LineEdit  # Fixed the node name from LinEdit to LineEdit
@onready var rocket_status_label = $RocketStatusLabel
@onready var enter_button = $EnterButton
var correct_command = "python manage.py runserver"
var is_rocket_online = false

func _ready():
	# The UI should be initialized but not visible
	# This will be set to visible when instantiated by the dashboard
	if get_parent() != null:
		# Start hidden by default
		visible = false
	
	# Connect the enter button press signal
	if enter_button:
		enter_button.pressed.connect(_on_enter_button_pressed)
	
	# Set initial rocket status
	update_rocket_status(false)

func _on_enter_button_pressed():
	validate_command()

func _input(event):
	# Only process input if the UI is visible
	if not visible:
		return
	
	# Removed the ability to close with Escape key
	
	# Check for Enter key press when the line edit has focus
	if line_edit and line_edit.has_focus() and event is InputEventKey:
		if event.pressed and event.keycode == KEY_ENTER:
			validate_command()

func validate_command():
	var input_text = line_edit.text.strip_edges()
	
	if input_text == correct_command:
		print("Correct command entered!")
		update_rocket_status(true)
		
		# Wait a moment before transitioning to the next scene
		var timer = get_tree().create_timer(2.0)
		timer.timeout.connect(func(): 
			print("Transitioning to next scene...")
			get_tree().change_scene_to_file("res://Minigame Scenes and Scripts/Chapter 1/chapter_1_world_part_5.tscn")
		)
	else:
		print("Incorrect command. Try again!")
		# Show error message
		show_error_message("Error: Invalid command")
		# Clear the input field
		line_edit.text = ""

func update_rocket_status(online: bool):
	is_rocket_online = online
	
	if rocket_status_label:
		if online:
			rocket_status_label.text = "Rocket Status: Online"
			rocket_status_label.add_theme_color_override("font_color", Color(0, 1, 0))  # Green color
		else:
			rocket_status_label.text = "Rocket Status: Offline"
			rocket_status_label.add_theme_color_override("font_color", Color(1, 0, 0))  # Red color

func show_error_message(error_text: String):
	if rocket_status_label:
		# Save the current text to restore later
		var original_text = rocket_status_label.text
		var original_color = rocket_status_label.get_theme_color("font_color", "")
		
		# Display error message
		rocket_status_label.text = error_text
		rocket_status_label.add_theme_color_override("font_color", Color(1, 0.5, 0))  # Orange color for errors
		
		# Set a timer to revert back to the original status after 1.5 seconds
		var timer = get_tree().create_timer(1.5)
		timer.timeout.connect(func():
			# Reset to the original status (offline)
			update_rocket_status(false)
		)

# This function remains but is no longer accessible to the player
func close_dashboard():
	visible = false
	emit_signal("closed")

# Called when the UI becomes visible
func show_dashboard():
	visible = true
	
	# Clear any pending input events
	get_viewport().set_input_as_handled()
	
	if line_edit:
		# Clear the text and set focus after a tiny delay to avoid capturing the 'F' input
		line_edit.text = ""
		var timer = get_tree().create_timer(0.1)
		timer.timeout.connect(func(): 
			line_edit.grab_focus()
		);
