# scenes/UI/save_game_ui.gd
extends Control

@onready var slot_button_1: Button = $PanelContainer/VBoxContainer/SaveSlotButton1
@onready var slot_button_2: Button = $PanelContainer/VBoxContainer/SaveSlotButton2
@onready var slot_button_3: Button = $PanelContainer/VBoxContainer/SaveSlotButton3
@onready var message_label: Label = $PanelContainer/VBoxContainer/MessageLabel
@onready var cancel_button: Button = $PanelContainer/VBoxContainer/CancelButton
@onready var overwrite_dialog: ConfirmationDialog = $OverwriteConfirmationDialog

@onready var save_manager = get_node("/root/SaveManager")
@onready var character_data = get_node("/root/CharacterData")

var slot_buttons: Array[Button]
var current_slot_to_save: int = -1

func _ready():
	slot_buttons = [slot_button_1, slot_button_2, slot_button_3]
	for i in range(slot_buttons.size()):
		slot_buttons[i].pressed.connect(_on_save_slot_pressed.bind(i))

	cancel_button.pressed.connect(hide_ui)
	overwrite_dialog.confirmed.connect(_on_overwrite_confirmed)
	if save_manager:
		save_manager.save_slots_updated.connect(update_slot_displays) # Refresh if data changes

	self.visible = false

func show_ui():
	if not save_manager or not character_data:
		printerr("SaveGameUI: Critical manager nodes not found!")
		message_label.text = "Error: Save system unavailable."
		# Potentially disable all buttons
		return

	update_slot_displays()
	message_label.text = "" # Clear previous messages
	self.visible = true
	get_tree().paused = true

func hide_ui():
	self.visible = false
	get_tree().paused = false
	current_slot_to_save = -1

func update_slot_displays():
	if not save_manager: return
	var slots_info = save_manager.get_all_save_slots_info()
	for i in range(slot_buttons.size()):
		if i < slots_info.size():
			var data = slots_info[i]
			var text = "Slot %s: " % (i + 1)
			if data.get("slot_in_use", false):
				var p_name = data.get("player_name", "N/A")
				var timestamp = data.get("timestamp", 0)
				var date_str = Time.get_datetime_string_from_unix_time(timestamp).replace("T", " ") if timestamp > 0 else "No Date"
				text += "%s - %s" % [p_name, date_str]
			else:
				text += "(Empty)"
			slot_buttons[i].text = text
		else: # Should not happen if SAVE_SLOT_COUNT matches buttons
			slot_buttons[i].text = "Slot %s: (Error)" % (i+1)
			slot_buttons[i].disabled = true


func _on_save_slot_pressed(slot_index: int):
	current_slot_to_save = slot_index
	message_label.text = ""

	var slot_info = save_manager.get_save_slot_info(slot_index)
	if slot_info.get("slot_in_use", false):
		overwrite_dialog.popup_centered()
	else:
		_perform_save()

func _on_overwrite_confirmed():
	_perform_save()

func _perform_save():
	if current_slot_to_save == -1: return

	var game_data_for_slot = { # We'll let SaveManager pull most from CharacterData
		"player_name": character_data.player_name, # This is good to have explicitly for display
		# Add any other specific state from the current scene if necessary,
		# but current_scene_path is handled by SaveManager.
	}

	if save_manager.save_game(current_slot_to_save, game_data_for_slot):
		message_label.text = "Game saved to Slot %s!" % (current_slot_to_save + 1)
		# Optionally, update_slot_displays() can be called here or rely on signal
		# Consider auto-closing after a short delay:
		# get_tree().create_timer(1.5).timeout.connect(hide_ui)
	else:
		message_label.text = "Error saving game to Slot %s." % (current_slot_to_save + 1)
	# current_slot_to_save = -1 # Reset after attempt, or in hide_ui

func _input(event: InputEvent): # Or you can rename to _unhandled_input if you prefer
	if self.visible and Input.is_action_just_pressed("ui_cancel"): # CORRECTED LINE
		print("DEBUG: save_game_ui - ui_cancel detected, calling hide_ui()")
		hide_ui()
		# It's good practice to mark the event as handled if you've processed it,
		# especially in UI, to prevent other elements from also processing it.
		get_tree().get_root().set_input_as_handled()
