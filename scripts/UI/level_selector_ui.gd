# scenes/UI/level_selector_ui.gd
extends Control

@onready var title_label: Label = $PanelContainer/VBoxContainer/TitleLabel
@onready var level_1_button: Button = $PanelContainer/VBoxContainer/Level1Button
@onready var level_2_button: Button = $PanelContainer/VBoxContainer/Level2Button
@onready var level_3_button: Button = $PanelContainer/VBoxContainer/Level3Button
@onready var level_4_button: Button = $PanelContainer/VBoxContainer/Level4Button
@onready var close_button: Button = $PanelContainer/VBoxContainer/CloseButton

@onready var character_data = get_node("/root/CharacterData")

# IMPORTANT: Define the actual scene paths for your levels
const LEVEL_SCENE_PATHS = [
	"res://scenes/Levels/Chapter 1/chapter_1_world_part_1.tscn", # Or intro cutscene for full replay
	"res://scenes/Levels/Chapter 2/rocket_travelling_to_chapter_2_world.tscn", # REPLACE WITH ACTUAL PATH
	"res://scenes/Levels/Chapter 3 (5-24-25)/Story Flow World 3/rocket_travelling_to_chapter_3_world.tscn", # REPLACE WITH ACTUAL PATH
	"res://scenes/Levels/Chapter 4/rocket_travelling_to_chapter_4_world.tscn"  # REPLACE WITH ACTUAL PATH
]
# User-friendly names for buttons
const LEVEL_NAMES = [
	"Chapter 1 - Setting Up Django",
	"Chapter 2 - URLs,  Views, Templates and Static Files", # REPLACE
	"Chapter 3 - Models, Database and Admin Panels", # REPLACE
	"Chapter 4 - Return to Earth - Deployment" # REPLACE
]


func _ready():
	level_1_button.pressed.connect(_on_level_button_pressed.bind(0))
	level_2_button.pressed.connect(_on_level_button_pressed.bind(1))
	level_3_button.pressed.connect(_on_level_button_pressed.bind(2))
	level_4_button.pressed.connect(_on_level_button_pressed.bind(3))
	close_button.pressed.connect(hide_ui)
	self.visible = false # Ensure it's hidden at start

func show_ui():
	if not character_data:
		printerr("LevelSelectorUI: CharacterData not found!")
		return

	level_1_button.text = LEVEL_NAMES[0]
	level_1_button.disabled = not character_data.unlocked_level_1 # Should always be true here

	level_2_button.text = LEVEL_NAMES[1] + (" (Locked)" if not character_data.unlocked_level_2 else "")
	level_2_button.disabled = not character_data.unlocked_level_2

	level_3_button.text = LEVEL_NAMES[2] + (" (Locked)" if not character_data.unlocked_level_3 else "")
	level_3_button.disabled = not character_data.unlocked_level_3

	level_4_button.text = LEVEL_NAMES[3] + (" (Locked)" if not character_data.unlocked_level_4 else "")
	level_4_button.disabled = not character_data.unlocked_level_4

	self.visible = true
	get_tree().paused = true # Pause the game

func hide_ui():
	self.visible = false
	get_tree().paused = false # Unpause the game

func _on_level_button_pressed(level_index: int):
	if level_index < 0 or level_index >= LEVEL_SCENE_PATHS.size():
		printerr("LevelSelectorUI: Invalid level index ", level_index)
		return

	var scene_path = LEVEL_SCENE_PATHS[level_index]
	if scene_path.is_empty() or "placeholder" in scene_path :
		printerr("LevelSelectorUI: Scene path for level ", level_index + 1, " is not valid: ", scene_path)
		# Optionally show a message to the player
		return

	hide_ui()
	var result = get_tree().change_scene_to_file(scene_path)
	if result != OK:
		printerr("LevelSelectorUI: Failed to change scene to ", scene_path, ". Error: ", result)

func _input(event: InputEvent): # Or you can rename to _unhandled_input if you prefer
	if self.visible and Input.is_action_just_pressed("ui_cancel"): # CORRECTED LINE
		print("DEBUG: level_selector_ui - ui_cancel detected, calling hide_ui()")
		hide_ui()
		# It's good practice to mark the event as handled if you've processed it,
		# especially in UI, to prevent other elements from also processing it.
		get_tree().get_root().set_input_as_handled()
