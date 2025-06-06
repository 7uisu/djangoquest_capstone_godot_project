# ============================================
# ENHANCED GAME CONTROLLER - KEEPING ORIGINAL + ADDING MORE
# REPLACE YOUR EXISTING chapter_2_world_2nd_minigame_pt2.gd WITH THIS
# ============================================

extends Node2D
class_name Chapter2World2ndMinigamePt2Fixed

# Game state - EXPANDED PHASES (KEPT ORIGINAL + ADDED MORE)
enum Phase { 
	TEMPLATE,          # Phase 1: Original template repair
	CSS,               # Phase 2: Original CSS repair  
	STATIC_FILES,      # Phase 3: NEW - Static files loading
	TEMPLATE_TAGS      # Phase 4: NEW - Template logic tags
}

@export var current_phase: Phase = Phase.TEMPLATE

# Lives system (increased slightly for more phases)
@export var max_lives: int = 4
var current_lives: int = 4

# Node references (SAME AS ORIGINAL)
@onready var robot_sprite = $RobotDisplay/RobotSprite
@onready var robot_screen = $RobotDisplay/RobotScreen
@onready var health_bar = $RobotDisplay/HealthBar
@onready var lives_display = $GameUI/LivesDisplay
@onready var phase_title = $GameUI/PhasePanel/PhaseTitle
@onready var status_text = $GameUI/PhasePanel/StatusText
@onready var code_editor = $GameUI/CodeEditor
@onready var error_display = $ErrorDisplay
@onready var respawn_ui = $RespawnUI

# Drag buttons (SAME AS ORIGINAL)
@onready var drag_button1 = $GameUI/DragArea/DragButton1
@onready var drag_button2 = $GameUI/DragArea/DragButton2
@onready var drag_button3 = $GameUI/DragArea/DragButton3
@onready var drag_button4 = $GameUI/DragArea/DragButton4

# Drop zones (SAME AS ORIGINAL)
@onready var drop_zone1 = $GameUI/DropZones/DropZone1
@onready var drop_zone2 = $GameUI/DropZones/DropZone2

# Game data (SAME AS ORIGINAL)
var current_drops = {
	"drop_zone1": "",
	"drop_zone2": ""
}

# EXPANDED Phase data - KEPT ORIGINAL + ADDED 2 MORE
var phase_data = {
	# ORIGINAL PHASES (KEPT EXACTLY THE SAME)
	Phase.TEMPLATE: {
		"title": "Phase 1: Template Repair",
		"status": "Fix Django template variables and block tags",
		"drag_items": ["title-display", "content-face", "disk", "block_chain"],
		"zone_labels": {
			"drop_zone1": "{{ ___ }}",
			"drop_zone2": "{% block ___ %}"
		}
	},
	Phase.CSS: {
		"title": "Phase 2: CSS Repair", 
		"status": "Fix CSS properties for robot's display and face color",
		"drag_items": ["black", "white", "green", "blue"],
		"zone_labels": {
			"drop_zone1": "background-color: ___;",
			"drop_zone2": "face-color: ___;"
		}
	},
	
	# NEW PHASES (ADDED)
	Phase.STATIC_FILES: {
		"title": "Phase 3: Static Files Setup",
		"status": "Fix static files loading for robot resources",
		"drag_items": ["load static", "static", "STATIC_URL", "css"],
		"zone_labels": {
			"drop_zone1": "{% ___ %}",
			"drop_zone2": "{% ___ 'robot.css' %}"
		}
	},
	Phase.TEMPLATE_TAGS: {
		"title": "Phase 4: Template Logic",
		"status": "Fix template logic for robot status display",
		"drag_items": ["for", "if", "endif", "endfor"],
		"zone_labels": {
			"drop_zone1": "{% ___ robot.is_active %}",
			"drop_zone2": "{% ___ component in parts %}"
		}
	}
}

# EXPANDED Correct answers - KEPT ORIGINAL + ADDED MORE
var correct_answers = {
	# ORIGINAL ANSWERS (KEPT EXACTLY THE SAME)
	Phase.TEMPLATE: {
		"drop_zone1": "title-display",
		"drop_zone2": "content-face"
	},
	Phase.CSS: {
		"drop_zone1": "black",
		"drop_zone2": "green"
	},
	
	# NEW ANSWERS (ADDED)
	Phase.STATIC_FILES: {
		"drop_zone1": "load static",
		"drop_zone2": "static"
	},
	Phase.TEMPLATE_TAGS: {
		"drop_zone1": "if",
		"drop_zone2": "for"
	}
}

# Phase progression
var phase_order = [Phase.TEMPLATE, Phase.CSS, Phase.STATIC_FILES, Phase.TEMPLATE_TAGS]
var current_phase_index: int = 0

# ALL ORIGINAL FUNCTIONS KEPT THE SAME (NO CHANGES)
func _ready():
	setup_lives_system()
	setup_drop_zones()
	setup_phase(Phase.TEMPLATE)
	setup_respawn_ui()
	update_robot_status("damaged")

func setup_lives_system():
	current_lives = max_lives
	update_hearts_display()

func setup_drop_zones():
	if drop_zone1:
		drop_zone1.zone_id = "drop_zone1"
		if not drop_zone1.item_dropped.is_connected(_on_item_dropped):
			drop_zone1.item_dropped.connect(_on_item_dropped)
		
	if drop_zone2:
		drop_zone2.zone_id = "drop_zone2"
		if not drop_zone2.item_dropped.is_connected(_on_item_dropped):
			drop_zone2.item_dropped.connect(_on_item_dropped)

func setup_respawn_ui():
	print("Setting up respawn UI...")
	
	if not respawn_ui:
		print("ERROR: RespawnUI node not found!")
		return
		
	respawn_ui.visible = false
	respawn_ui.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	respawn_ui.mouse_filter = Control.MOUSE_FILTER_STOP
	
	var respawn_btn = null
	var quit_btn = null
	
	var respawn_paths = [
		"RespawnPanel/ButtonContainer/RespawnButton",
		"RespawnButton", 
		"ButtonContainer/RespawnButton"
	]
	
	var quit_paths = [
		"RespawnPanel/ButtonContainer/QuitButton",
		"QuitButton",
		"ButtonContainer/QuitButton"
	]
	
	for path in respawn_paths:
		respawn_btn = respawn_ui.get_node_or_null(path)
		if respawn_btn:
			print("Found respawn button at: ", path)
			break
	
	for path in quit_paths:
		quit_btn = respawn_ui.get_node_or_null(path)
		if quit_btn:
			print("Found quit button at: ", path)
			break
	
	if respawn_btn:
		if respawn_btn.pressed.is_connected(_on_respawn_button_pressed):
			respawn_btn.pressed.disconnect(_on_respawn_button_pressed)
		
		respawn_btn.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
		respawn_btn.pressed.connect(_on_respawn_button_pressed)
		respawn_btn.mouse_filter = Control.MOUSE_FILTER_STOP
		respawn_btn.disabled = false
		
		print("Respawn button connected successfully")
	else:
		print("ERROR: Could not find respawn button!")
		
	if quit_btn:
		if quit_btn.pressed.is_connected(_on_quit_button_pressed):
			quit_btn.pressed.disconnect(_on_quit_button_pressed)
		
		quit_btn.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
		quit_btn.pressed.connect(_on_quit_button_pressed)
		quit_btn.mouse_filter = Control.MOUSE_FILTER_STOP
		quit_btn.disabled = false
		
		print("Quit button connected successfully")
	else:
		print("ERROR: Could not find quit button!")
	
	var overlay = respawn_ui.get_node_or_null("Overlay")
	if overlay:
		overlay.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
		
	var panel = respawn_ui.get_node_or_null("RespawnPanel")
	if panel:
		panel.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
		
	var button_container = respawn_ui.get_node_or_null("RespawnPanel/ButtonContainer")
	if button_container:
		button_container.process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func _on_respawn_button_pressed():
	print("Respawn button pressed!")
	
	if respawn_ui:
		respawn_ui.visible = false
	
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_button_pressed():
	print("Quit button pressed!")
	
	if respawn_ui:
		respawn_ui.visible = false
	
	get_tree().paused = false
	
	var main_menu_paths = [
		"res://scenes/UI/main_menu_ui.tscn",
		"res://scenes/main_menu.tscn", 
		"res://main_menu.tscn",
		"res://scenes/UI/MainMenu.tscn"
	]
	
	for path in main_menu_paths:
		if ResourceLoader.exists(path):
			print("Changing scene to: ", path)
			get_tree().change_scene_to_file(path)
			return
	
	print("No main menu scene found, quitting to desktop")
	get_tree().quit()

func setup_phase(phase: Phase):
	current_phase = phase
	var data = phase_data[phase]
	
	current_drops = {"drop_zone1": "", "drop_zone2": ""}
	
	if phase_title:
		phase_title.text = data["title"]
		
	if status_text:
		status_text.text = data["status"]
		status_text.visible = true
	
	var drag_buttons = [drag_button1, drag_button2, drag_button3, drag_button4]
	for i in range(4):
		var button = drag_buttons[i]
		if button:
			var item_text = data["drag_items"][i]
			button.setup(item_text)
			button.visible = true
			button.disabled = false
	
	var zones = [drop_zone1, drop_zone2]
	for i in range(2):
		var zone = zones[i]
		if zone:
			zone.visible = true
			zone.reset_zone()
			var zone_key = "drop_zone" + str(i + 1)
			var label_text = data["zone_labels"][zone_key]
			zone.set_label_text(label_text)
	
	update_code_display()

func _on_item_dropped(zone_id: String, data: String):
	current_drops[zone_id] = data
	update_code_display()
	
	var both_filled = current_drops["drop_zone1"] != "" and current_drops["drop_zone2"] != ""
	
	if both_filled:
		check_phase_completion()

func check_phase_completion():
	var is_correct = true
	var correct_for_phase = correct_answers[current_phase]
	
	for zone_id in current_drops:
		var user_answer = current_drops[zone_id]
		var correct_answer = correct_for_phase[zone_id]
		if user_answer != correct_answer:
			is_correct = false
			break
	
	if is_correct:
		handle_correct_phase()
	else:
		handle_incorrect_phase()

# MODIFIED: Enhanced to handle all 4 phases
func handle_correct_phase():
	if health_bar:
		health_bar.value += 25  # Each phase gives 25% health
	
	match current_phase:
		Phase.TEMPLATE:
			update_robot_screen()
			update_robot_status("display_fixed")
			get_tree().create_timer(1.0).timeout.connect(func():
				setup_phase(Phase.CSS)
			)
		Phase.CSS:
			update_robot_buttons()
			update_robot_status("styling_fixed")
			get_tree().create_timer(1.0).timeout.connect(func():
				setup_phase(Phase.STATIC_FILES)
			)
		Phase.STATIC_FILES:
			update_robot_status("static_loaded")
			get_tree().create_timer(1.0).timeout.connect(func():
				setup_phase(Phase.TEMPLATE_TAGS)
			)
		Phase.TEMPLATE_TAGS:
			complete_game()

# MODIFIED: Enhanced error messages for new phases
func handle_incorrect_phase():
	show_phase_error()
	lose_life()
	
	get_tree().create_timer(2.0).timeout.connect(func():
		if current_lives > 0:
			reset_current_phase()
	)

func show_phase_error():
	var message = ""
	
	match current_phase:
		Phase.TEMPLATE:
			message = "Template error! Wrong\n configuration"
		Phase.CSS:
			message = "CSS error! Wrong\n display and face color."
		Phase.STATIC_FILES:
			message = "Static Files error! Wrong\n loading configuration."
		Phase.TEMPLATE_TAGS:
			message = "Template Tags error! Wrong\n logic syntax."
	
	show_error_message(message)

# ALL OTHER FUNCTIONS KEPT EXACTLY THE SAME AS ORIGINAL...
func reset_current_phase():
	if drop_zone1:
		drop_zone1.reset_zone()
		
	if drop_zone2:
		drop_zone2.reset_zone()
	
	current_drops = {"drop_zone1": "", "drop_zone2": ""}
	
	var drag_buttons = [drag_button1, drag_button2, drag_button3, drag_button4]
	for button in drag_buttons:
		if button:
			button.disabled = false
			button.position = button.original_position
	
	update_code_display()

func lose_life():
	if current_lives > 0:
		current_lives -= 1
		animate_heart_loss(current_lives)
		update_hearts_display()
		
		if current_lives <= 0:
			show_respawn_ui()

func animate_heart_loss(heart_index: int):
	if not lives_display:
		return
		
	var child_count = lives_display.get_child_count()
	
	if heart_index < child_count:
		var heart = lives_display.get_child(heart_index)
		if heart:
			var tween = create_tween()
			tween.tween_property(heart, "modulate", Color.TRANSPARENT, 0.5)
			tween.tween_callback(func(): 
				heart.visible = false
			)

func update_hearts_display():
	if not lives_display:
		return
		
	var hearts = lives_display.get_children()
	
	for i in range(hearts.size()):
		if hearts[i]:
			if i < current_lives:
				hearts[i].visible = true
				hearts[i].modulate = Color.WHITE
			else:
				hearts[i].visible = false

func show_respawn_ui():
	print("Showing respawn UI...")
	
	if respawn_ui:
		respawn_ui.visible = true
		respawn_ui.mouse_filter = Control.MOUSE_FILTER_STOP
		respawn_ui.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
		
		var overlay = respawn_ui.get_node_or_null("Overlay")
		if overlay:
			overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
			overlay.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
			
		var panel = respawn_ui.get_node_or_null("RespawnPanel")
		if panel:
			panel.mouse_filter = Control.MOUSE_FILTER_STOP
			panel.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
			
		var respawn_btn = respawn_ui.get_node_or_null("RespawnPanel/ButtonContainer/RespawnButton")
		var quit_btn = respawn_ui.get_node_or_null("RespawnPanel/ButtonContainer/QuitButton")
		
		if respawn_btn:
			respawn_btn.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
		if quit_btn:
			quit_btn.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
			
		var button_container = respawn_ui.get_node_or_null("RespawnPanel/ButtonContainer")
		if button_container:
			button_container.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
		
		get_tree().paused = true
		
		print("Respawn UI should now be visible and interactive")
	else:
		print("ERROR: Cannot show respawn UI - node is null!")

func complete_game():
	update_robot_status("fully_restored")
	show_success_message("Robot Interface Fully Restored!")
	
	get_tree().create_timer(2.0).timeout.connect(func():
		print("Minigame completed! Transitioning to next scene...")
		
		# Choose the destination based on which version you want
		var next_scene_path = "res://scenes/Levels/Chapter 2/chapter_2_world_part_6.tscn"
		
		if ResourceLoader.exists(next_scene_path):
			print("Loading next scene: ", next_scene_path)
			get_tree().change_scene_to_file(next_scene_path)
		else:
			print("ERROR: Next scene not found at: ", next_scene_path)
			print("Falling back to main menu or staying in current scene")
	)

# MODIFIED: Enhanced robot status for new phases
func update_robot_status(status: String):
	match status:
		"damaged":
			if robot_sprite:
				robot_sprite.modulate = Color.GRAY
			if status_text:
				status_text.text = "Interface: Damaged - Display blank"
		"display_fixed":
			if status_text:
				status_text.text = "Interface: Display Fixed - Still needs styling"
		"styling_fixed":
			if status_text:
				status_text.text = "Interface: Styling Applied - Loading static files"
		"static_loaded":
			if status_text:
				status_text.text = "Interface: Static Files Loaded - Adding logic"
		"fully_restored":
			if robot_sprite:
				robot_sprite.modulate = Color.GREEN
			if status_text:
				status_text.text = "Interface: Fully Restored! Robot is ready!"

func update_robot_screen():
	if not robot_screen:
		return
		
	var screen_container = robot_screen.get_node_or_null("ScreenContainer/ScreenContent")
	if not screen_container:
		return
	
	var welcome_label = screen_container.get_node_or_null("WelcomeLabel")
	if welcome_label:
		welcome_label.text = "Robot Interface Active"
		welcome_label.visible = true
	
	var status_label = screen_container.get_node_or_null("StatusLabel")
	if status_label:
		status_label.text = "Content Block Loaded"
		status_label.visible = true

func update_robot_buttons():
	if not robot_screen:
		return
		
	var robot_buttons = robot_screen.get_node_or_null("ScreenContainer/RobotButtons")
	if not robot_buttons:
		return
		
	var buttons = robot_buttons.get_children()
	
	for button in buttons:
		if button:
			button.add_theme_color_override("normal", Color.html("#00FF00"))
			button.add_theme_color_override("font_color", Color.WHITE)

func show_error_message(message: String):
	if not error_display:
		return
		
	var error_text = error_display.get_node_or_null("ErrorText")
	if error_text:
		error_text.text = message
	
	error_display.show()
	
	get_tree().create_timer(2.0).timeout.connect(func(): 
		if error_display:
			error_display.hide()
	)

func show_success_message(message: String):
	print("SUCCESS: ", message)

# MODIFIED: Enhanced code display for new phases
# FIXED: Enhanced code display for new phases - Clean display when correct
func update_code_display():
	if not code_editor:
		return
		
	var code_text = code_editor.get_node_or_null("CodeText")
	if not code_text:
		return
	
	match current_phase:
		Phase.TEMPLATE:
			var blank1 = current_drops.get("drop_zone1", "")
			var blank2 = current_drops.get("drop_zone2", "")
			
			# Show clean version when filled, placeholder when empty
			var display1 = blank1 if blank1 != "" else "____"
			var display2 = blank2 if blank2 != "" else "____"
			
			var template = """<title>{{ %s }}</title>
<div>
  {%% block %s %%}
  {%% endblock %%}
</div>"""
			code_text.text = template % [display1, display2]
			
		Phase.CSS:
			var bg = current_drops.get("drop_zone1", "")
			var color = current_drops.get("drop_zone2", "")
			
			# Show clean version when filled, placeholder when empty
			var display_bg = bg if bg != "" else "____"
			var display_color = color if color != "" else "____"
			
			var css = """.robot-btn {
  background-color: %s;
  face-color: %s;
}"""
			code_text.text = css % [display_bg, display_color]
			
		Phase.STATIC_FILES:
			var load_tag = current_drops.get("drop_zone1", "")
			var static_tag = current_drops.get("drop_zone2", "")
			
			# Show clean version when filled, placeholder when empty
			var display_load = ("{% " + load_tag + " %}") if load_tag != "" else "{% ____ %}"
			var display_static = ("{% " + static_tag + " 'robot.css' %}") if static_tag != "" else "{% ____ 'robot.css' %}"
			
			var static_template = """%s
<link rel="stylesheet" href="%s">"""
			code_text.text = static_template % [display_load, display_static]
			
		Phase.TEMPLATE_TAGS:
			var if_tag = current_drops.get("drop_zone1", "")
			var for_tag = current_drops.get("drop_zone2", "")
			
			# Show clean version when filled, placeholder when empty
			var display_if = ("{% " + if_tag + " robot.is_active %}") if if_tag != "" else "{% ____ robot.is_active %}"
			var display_for = ("{% " + for_tag + " component in parts %}") if for_tag != "" else "{% ____ component in parts %}"
			
			var logic_template = """%s
  <span>Robot Active</span>
{%% endif %%}
%s
  <div>{{ component }}</div>
{%% endfor %%}"""
			code_text.text = logic_template % [display_if, display_for]

func reset_entire_game():
	print("Resetting entire game...")
	
	current_lives = max_lives
	update_hearts_display()
	
	current_phase = Phase.TEMPLATE
	
	if health_bar:
		health_bar.value = 0
	
	reset_robot_screen()
	update_robot_status("damaged")
	setup_phase(Phase.TEMPLATE)
	
	print("Game reset complete!")

func reset_robot_screen():
	if not robot_screen:
		return
		
	var screen_container = robot_screen.get_node_or_null("ScreenContainer/ScreenContent")
	if screen_container:
		var welcome_label = screen_container.get_node_or_null("WelcomeLabel")
		var status_label = screen_container.get_node_or_null("StatusLabel")
		
		if welcome_label:
			welcome_label.text = ""
			welcome_label.visible = false
		if status_label:
			status_label.text = ""
			status_label.visible = false
	
	var robot_buttons = robot_screen.get_node_or_null("ScreenContainer/RobotButtons")
	if robot_buttons:
		var buttons = robot_buttons.get_children()
		for button in buttons:
			if button:
				button.remove_theme_color_override("normal")
				button.remove_theme_color_override("font_color")

func test_respawn_ui():
	print("=== TESTING RESPAWN UI ===")
	show_respawn_ui()
