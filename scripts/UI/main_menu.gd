#main_menu.gd
extends Node

@onready var quit_dialog: ConfirmationDialog = $QuitConfirmationDialog
# Assuming your buttons are in a VBoxContainer or similar direct child of MainMenu node
@onready var play_button: Button = $MenuButtons/PlayButton # Adjust path as needed
@onready var continue_button: Button = $MenuButtons/ContinueButton # Adjust path
@onready var main_menu_buttons_container: Container = $MenuButtons # The container holding Play, Continue, Quit etc.

# Add a Label node to your main_menu.tscn for messages like "All slots full"
@onready var info_message_label: Label = $InfoMessageLabel # Adjust path

@export var load_game_ui_scene: PackedScene # Assign res://scenes/UI/load_game_ui.tscn in Inspector

var load_game_ui_instance = null

@onready var save_manager = get_node("/root/SaveManager")
@onready var character_data = get_node("/root/CharacterData")

func _ready():
	quit_dialog.confirmed.connect(_on_quit_confirmation_dialog_confirmed)
	quit_dialog.canceled.connect(_on_quit_confirmation_dialog_canceled) # Though it hides by default

	play_button.pressed.connect(_on_play_button_pressed)
	# $VBoxContainer/QuitButton.pressed.connect(_on_quit_button_pressed) # Ensure this is connected in editor or here
	continue_button.pressed.connect(_on_continue_button_pressed)

	if info_message_label:
		info_message_label.visible = false # Hide initially

	# Update continue button based on save file existence
	update_continue_button_state()
	if save_manager: # Connect to signal for future updates
		save_manager.save_slots_updated.connect(update_continue_button_state)


func update_continue_button_state():
	if not save_manager:
		continue_button.disabled = true
		return
	var has_saves = false
	for i in range(save_manager.SAVE_SLOT_COUNT):
		if save_manager.get_save_slot_info(i).get("slot_in_use", false):
			has_saves = true
			break
	continue_button.disabled = not has_saves

func _on_play_button_pressed() -> void:
	if info_message_label: info_message_label.visible = false # Clear previous messages

	if save_manager.are_all_slots_full():
		if info_message_label:
			info_message_label.text = "All save slots are full. Please delete a save via 'Continue' to start a new game."
			info_message_label.visible = true
		print("MainMenu: All slots full. Cannot start new game.")
		return

	# Prepare CharacterData for a new game (name/gender will be set in subsequent scenes)
	if character_data:
		character_data.reset_data() # Reset name, gender, unlocked levels
	if save_manager:
		save_manager.prepare_new_game_session_data()

	get_tree().change_scene_to_file("res://scenes/Cutscenes/introduction_cutscene.tscn")

func _on_continue_button_pressed() -> void:
	if info_message_label: info_message_label.visible = false

	if not load_game_ui_scene:
		printerr("MainMenu: load_game_ui_scene not set in Inspector!")
		if info_message_label:
			info_message_label.text = "Error: Load Game UI is not available."
			info_message_label.visible = true
		return

	if not load_game_ui_instance or not is_instance_valid(load_game_ui_instance):
		load_game_ui_instance = load_game_ui_scene.instantiate()
		add_child(load_game_ui_instance) # Add it to the MainMenu scene itself
		if not load_game_ui_instance.is_connected("back_to_main_menu", Callable(self, "_on_load_ui_closed")) :
			load_game_ui_instance.connect("back_to_main_menu", Callable(self, "_on_load_ui_closed"))


	if load_game_ui_instance and load_game_ui_instance.has_method("show_ui"):
		if main_menu_buttons_container:
			main_menu_buttons_container.visible = false # Hide main menu buttons
		load_game_ui_instance.show_ui()
	else:
		printerr("MainMenu: Failed to instance or show Load Game UI.")
		if info_message_label:
			info_message_label.text = "Error launching Load Game UI."
			info_message_label.visible = true


func _on_load_ui_closed():
	# This is called when the LoadGameUI emits "back_to_main_menu"
	if main_menu_buttons_container:
		main_menu_buttons_container.visible = true # Show main menu buttons again
	update_continue_button_state() # In case a save was deleted

func _on_quit_button_pressed() -> void: # Make sure this is connected from your Quit button
	quit_dialog.popup_centered()

func _on_quit_confirmation_dialog_confirmed() -> void:
	get_tree().quit()

func _on_quit_confirmation_dialog_canceled() -> void:
	# Dialog hides itself, no action needed unless you want something specific
	pass
