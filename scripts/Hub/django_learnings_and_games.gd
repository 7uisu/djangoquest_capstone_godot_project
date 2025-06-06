# scenes/UI/django_learning_and_games.gd
extends Control

# Book UI Buttons (PanelContainer)
@onready var book_level_1_button: Button = $PanelContainer/VBoxContainer/Level1Button
@onready var book_level_2_button: Button = $PanelContainer/VBoxContainer/Level2Button
@onready var book_level_3_button: Button = $PanelContainer/VBoxContainer/Level3Button
@onready var book_level_4_button: Button = $PanelContainer/VBoxContainer/Level4Button

# Game Buttons (PanelContainer2)
@onready var game_level_1_button: Button = $PanelContainer2/VBoxContainer/Level1Button
@onready var game_level_2_button: Button = $PanelContainer2/VBoxContainer/Level2Button
@onready var game_level_3_button: Button = $PanelContainer2/VBoxContainer/Level3Button
@onready var game_level_4_button: Button = $PanelContainer2/VBoxContainer/Level4Button

@onready var close_button: Button = $CloseButton

# Book UI References (will be found in hub_area's UILayer)
var django_book_chapter_1: Control
var django_book_chapter_2: Control
var django_book_chapter_3: Control
var django_book_chapter_4: Control
var hub_ui_layer: Node

@onready var character_data = get_node("/root/CharacterData")

# Track which chapter is currently open
var current_open_chapter: Control = null

# Define book chapter names
const BOOK_CHAPTER_NAMES = [
	"Setting Up Django",
	"URLs,  Views,\nTemplates and Static Files",
	"Models, Database\nand Admin Panel",
	"Return to\nEarth - Deployment"
]

# Define game names
const GAME_NAMES = [
	"Setting Up Django",
	"URLs,  Views, Templates\nand Static Files",
	"Models, Databaseand\nAdmin Panel",
	"Return to Earth\n- Deployment"
]

# Game scene paths (replace with your actual game scene paths)
const GAME_SCENE_PATHS = [
	"res://Minigame Scenes and Scripts/Chapter 1/chapter_1_world_part_3_2nd_minigame.tscn",        # Replace with actual path
	"res://Minigame Scenes and Scripts/Chapter 2/chapter_2_world_part_4_1st_minigame_pt1.tscn",        # Replace with actual path
	"res://scenes/Games/model_building_game.tscn",      # Replace with actual path
	"res://scenes/Games/deployment_challenge.tscn"      # Replace with actual path
]

func _ready():
	# Connect book buttons
	book_level_1_button.pressed.connect(_on_book_button_pressed.bind(0))
	book_level_2_button.pressed.connect(_on_book_button_pressed.bind(1))
	book_level_3_button.pressed.connect(_on_book_button_pressed.bind(2))
	book_level_4_button.pressed.connect(_on_book_button_pressed.bind(3))
	
	# Connect game buttons
	game_level_1_button.pressed.connect(_on_game_button_pressed.bind(0))
	game_level_2_button.pressed.connect(_on_game_button_pressed.bind(1))
	game_level_3_button.pressed.connect(_on_game_button_pressed.bind(2))
	game_level_4_button.pressed.connect(_on_game_button_pressed.bind(3))
	
	# Connect close button
	close_button.pressed.connect(hide_ui)
	
	# Find book UIs in hub area's UILayer
	_find_book_uis()
	
	# Hide all book UIs initially
	_hide_all_book_uis()
	
	# Hide main UI initially
	self.visible = false

func _find_book_uis():
	# Find the hub area's UILayer
	if get_tree().current_scene:
		hub_ui_layer = get_tree().current_scene.find_child("UILayer", true, false)
		if hub_ui_layer:
			# Find existing book UIs in the UILayer
			django_book_chapter_1 = hub_ui_layer.find_child("DjangoBookChapter1", false, false)
			django_book_chapter_2 = hub_ui_layer.find_child("DjangoBookChapter2", false, false)
			django_book_chapter_3 = hub_ui_layer.find_child("DjangoBookChapter3", false, false)
			django_book_chapter_4 = hub_ui_layer.find_child("DjangoBookChapter4", false, false)
			
			print("DjangoLearningAndGames: Book UIs found - Ch1:", django_book_chapter_1 != null, " Ch2:", django_book_chapter_2 != null, " Ch3:", django_book_chapter_3 != null, " Ch4:", django_book_chapter_4 != null)
		else:
			printerr("DjangoLearningAndGames: Could not find UILayer in hub area!")
	else:
		printerr("DjangoLearningAndGames: Current scene not available!")

func show_ui():
	if not character_data:
		printerr("DjangoLearningAndGames: CharacterData not found!")
		return
	
	# Try to find book UIs again if not found initially
	if not django_book_chapter_1:
		_find_book_uis()
	
	_update_button_states()
	self.visible = true
	get_tree().paused = true

func hide_ui():
	_hide_all_book_uis()
	current_open_chapter = null
	self.visible = false
	get_tree().paused = false

func _update_button_states():
	# Update book buttons - NOW USING BOOK/MINIGAME UNLOCK STATES
	book_level_1_button.text = BOOK_CHAPTER_NAMES[0]
	book_level_1_button.disabled = not character_data.unlocked_book_and_minigame_1
	
	book_level_2_button.text = BOOK_CHAPTER_NAMES[1] + (" (Locked)" if not character_data.unlocked_book_and_minigame_2 else "")
	book_level_2_button.disabled = not character_data.unlocked_book_and_minigame_2
	
	book_level_3_button.text = BOOK_CHAPTER_NAMES[2] + (" (Locked)" if not character_data.unlocked_book_and_minigame_3 else "")
	book_level_3_button.disabled = not character_data.unlocked_book_and_minigame_3
	
	book_level_4_button.text = BOOK_CHAPTER_NAMES[3] + (" (Locked)" if not character_data.unlocked_book_and_minigame_4 else "")
	book_level_4_button.disabled = not character_data.unlocked_book_and_minigame_4
	
	# Update game buttons - NOW USING BOOK/MINIGAME UNLOCK STATES
	game_level_1_button.text = GAME_NAMES[0]
	game_level_1_button.disabled = not character_data.unlocked_book_and_minigame_1
	
	game_level_2_button.text = GAME_NAMES[1] + (" (Locked)" if not character_data.unlocked_book_and_minigame_2 else "")
	game_level_2_button.disabled = not character_data.unlocked_book_and_minigame_2
	
	game_level_3_button.text = GAME_NAMES[2] + (" (Locked)" if not character_data.unlocked_book_and_minigame_3 else "")
	game_level_3_button.disabled = not character_data.unlocked_book_and_minigame_3
	
	game_level_4_button.text = GAME_NAMES[3] + (" (Locked)" if not character_data.unlocked_book_and_minigame_4 else "")
	game_level_4_button.disabled = not character_data.unlocked_book_and_minigame_4

func _on_book_button_pressed(chapter_index: int):
	print("DjangoLearningAndGames: Opening book chapter ", chapter_index + 1)
	
	# Make sure book UIs are found
	if not django_book_chapter_1:
		_find_book_uis()
	
	# Hide all book UIs first
	_hide_all_book_uis()
	
	# Show the selected chapter
	match chapter_index:
		0:
			if django_book_chapter_1:
				django_book_chapter_1.visible = true
				django_book_chapter_1.z_index = 110  # Bring to front
				current_open_chapter = django_book_chapter_1
				if django_book_chapter_1.has_method("show_ui"):
					django_book_chapter_1.show_ui()
				print("DjangoLearningAndGames: Chapter 1 UI shown")
			else:
				printerr("DjangoLearningAndGames: Chapter 1 UI not found!")
		1:
			if django_book_chapter_2:
				django_book_chapter_2.visible = true
				django_book_chapter_2.z_index = 110  # Bring to front
				current_open_chapter = django_book_chapter_2
				if django_book_chapter_2.has_method("show_ui"):
					django_book_chapter_2.show_ui()
				print("DjangoLearningAndGames: Chapter 2 UI shown")
			else:
				printerr("DjangoLearningAndGames: Chapter 2 UI not found!")
		2:
			if django_book_chapter_3:
				django_book_chapter_3.visible = true
				django_book_chapter_3.z_index = 110  # Bring to front
				current_open_chapter = django_book_chapter_3
				if django_book_chapter_3.has_method("show_ui"):
					django_book_chapter_3.show_ui()
				print("DjangoLearningAndGames: Chapter 3 UI shown")
			else:
				printerr("DjangoLearningAndGames: Chapter 3 UI not found!")
		3:
			if django_book_chapter_4:
				django_book_chapter_4.visible = true
				django_book_chapter_4.z_index = 110  # Bring to front
				current_open_chapter = django_book_chapter_4
				if django_book_chapter_4.has_method("show_ui"):
					django_book_chapter_4.show_ui()
				print("DjangoLearningAndGames: Chapter 4 UI shown")
			else:
				printerr("DjangoLearningAndGames: Chapter 4 UI not found!")

func _on_game_button_pressed(game_index: int):
	if game_index < 0 or game_index >= GAME_SCENE_PATHS.size():
		printerr("DjangoLearningAndGames: Invalid game index ", game_index)
		return
	
	var scene_path = GAME_SCENE_PATHS[game_index]
	if scene_path.is_empty() or "placeholder" in scene_path:
		printerr("DjangoLearningAndGames: Game scene path for level ", game_index + 1, " is not valid: ", scene_path)
		# Show a message to the player
		print("DjangoLearningAndGames: Game ", game_index + 1, " is not yet implemented.")
		return
	
	print("DjangoLearningAndGames: Starting game ", game_index + 1)
	hide_ui()
	
	var result = get_tree().change_scene_to_file(scene_path)
	if result != OK:
		printerr("DjangoLearningAndGames: Failed to change scene to ", scene_path, ". Error: ", result)

func _hide_all_book_uis():
	if django_book_chapter_1:
		django_book_chapter_1.visible = false
		if django_book_chapter_1.has_method("hide_ui"):
			django_book_chapter_1.hide_ui()
	
	if django_book_chapter_2:
		django_book_chapter_2.visible = false
		if django_book_chapter_2.has_method("hide_ui"):
			django_book_chapter_2.hide_ui()
	
	if django_book_chapter_3:
		django_book_chapter_3.visible = false
		if django_book_chapter_3.has_method("hide_ui"):
			django_book_chapter_3.hide_ui()
	
	if django_book_chapter_4:
		django_book_chapter_4.visible = false
		if django_book_chapter_4.has_method("hide_ui"):
			django_book_chapter_4.hide_ui()

func _input(event: InputEvent):
	if not self.visible:
		return
	
	# Check if ESC or Spacebar is pressed
	if Input.is_action_just_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode == KEY_SPACE):
		# If a chapter is currently open, close it and return to main menu
		if current_open_chapter and current_open_chapter.visible:
			print("DEBUG: django_learning_and_games - closing chapter and returning to main menu")
			if current_open_chapter.has_method("hide_ui"):
				current_open_chapter.hide_ui()
			current_open_chapter.visible = false
			current_open_chapter = null
			# Don't hide the main UI, just return to it
			get_tree().get_root().set_input_as_handled()
		else:
			# Only ESC closes the entire UI and returns to hub, spacebar does nothing
			if Input.is_action_just_pressed("ui_cancel"):
				print("DEBUG: django_learning_and_games - ESC detected, calling hide_ui()")
				hide_ui()
				get_tree().get_root().set_input_as_handled()

# Function to handle chapter closing from the chapter UI itself
func close_current_chapter():
	if current_open_chapter:
		print("DjangoLearningAndGames: Closing current chapter via method call")
		if current_open_chapter.has_method("hide_ui"):
			current_open_chapter.hide_ui()
		current_open_chapter.visible = false
		current_open_chapter = null

# Utility function to unlock a book/minigame level (can be called from other scripts)
func unlock_book_and_minigame_level(level_number: int):
	if character_data:
		match level_number:
			2: character_data.unlocked_book_and_minigame_2 = true
			3: character_data.unlocked_book_and_minigame_3 = true
			4: character_data.unlocked_book_and_minigame_4 = true
		print("DjangoLearningAndGames: Book and Minigame Level ", level_number, " unlocked!")
		_update_button_states() # Refresh button states
	else:
		printerr("DjangoLearningAndGames: CharacterData not found. Cannot unlock book and minigame level ", level_number)

# Debug function to check UI status
func debug_ui_status():
	print("=== DEBUG UI STATUS ===")
	print("Hub UILayer found: ", hub_ui_layer != null)
	print("Chapter 1 UI found: ", django_book_chapter_1 != null)
	print("Chapter 2 UI found: ", django_book_chapter_2 != null)
	print("Chapter 3 UI found: ", django_book_chapter_3 != null)
	print("Chapter 4 UI found: ", django_book_chapter_4 != null)
	print("Current open chapter: ", current_open_chapter)
	if django_book_chapter_1:
		print("Chapter 1 visible: ", django_book_chapter_1.visible)
		print("Chapter 1 z_index: ", django_book_chapter_1.z_index)
	print("Book/Minigame Unlock Status:")
	if character_data:
		print("  Level 1: ", character_data.unlocked_book_and_minigame_1)
		print("  Level 2: ", character_data.unlocked_book_and_minigame_2)
		print("  Level 3: ", character_data.unlocked_book_and_minigame_3)
		print("  Level 4: ", character_data.unlocked_book_and_minigame_4)
	print("========================")
