# load_game_ui.gd
# scenes/UI/load_game_ui.gd
extends Control

# Buttons for loading
@onready var load_button_1: Button = $PanelContainer/VBoxContainer/Slot1HBox/LoadSlotButton1
@onready var load_button_2: Button = $PanelContainer/VBoxContainer/Slot2HBox/LoadSlotButton2
@onready var load_button_3: Button = $PanelContainer/VBoxContainer/Slot3HBox/LoadSlotButton3
# Buttons for deleting
@onready var delete_button_1: Button = $PanelContainer/VBoxContainer/Slot1HBox/DeleteButton1
@onready var delete_button_2: Button = $PanelContainer/VBoxContainer/Slot2HBox/DeleteButton2
@onready var delete_button_3: Button = $PanelContainer/VBoxContainer/Slot3HBox/DeleteButton3

@onready var message_label: Label = $PanelContainer/VBoxContainer/MessageLabel
@onready var back_button: Button = $PanelContainer/VBoxContainer/BackButton
@onready var delete_confirm_dialog: ConfirmationDialog = $DeleteConfirmDialog

@onready var save_manager = get_node("/root/SaveManager")

var load_buttons: Array[Button]
var delete_buttons: Array[Button]
var current_slot_for_action: int = -1 # For delete or load

signal back_to_main_menu # To tell main_menu to reshow itself

func _ready():
	load_buttons = [load_button_1, load_button_2, load_button_3]
	delete_buttons = [delete_button_1, delete_button_2, delete_button_3]

	for i in range(load_buttons.size()):
		load_buttons[i].pressed.connect(_on_load_slot_pressed.bind(i))
		delete_buttons[i].pressed.connect(_on_delete_slot_pressed.bind(i))

	back_button.pressed.connect(_on_back_pressed)
	delete_confirm_dialog.confirmed.connect(_on_delete_confirmed)

	if save_manager:
		save_manager.save_slots_updated.connect(update_slot_displays)

	self.visible = false

func show_ui():
	if not save_manager:
		printerr("LoadGameUI: SaveManager not found!")
		message_label.text = "Error: Load system unavailable."
		return

	update_slot_displays()
	message_label.text = ""
	self.visible = true
	# No get_tree().paused = true here, as main menu is typically not paused

func hide_ui():
	self.visible = false
	current_slot_for_action = -1

func update_slot_displays():
	if not save_manager: return
	var slots_info = save_manager.get_all_save_slots_info()
	for i in range(load_buttons.size()):
		var data = slots_info[i]
		var text = "Slot %s: " % (i + 1)
		var is_in_use = data.get("slot_in_use", false)

		if is_in_use:
			var p_name = data.get("player_name", "N/A")
			var timestamp = data.get("timestamp", 0)
			var date_str = Time.get_datetime_string_from_unix_time(timestamp).replace("T", " ") if timestamp > 0 else "No Date"
			text += "%s - %s" % [p_name, date_str]
		else:
			text += "(Empty)"

		load_buttons[i].text = text
		load_buttons[i].disabled = not is_in_use
		delete_buttons[i].disabled = not is_in_use
		delete_buttons[i].visible = is_in_use # Hide delete button if slot is empty

func _on_load_slot_pressed(slot_index: int):
	message_label.text = ""
	if save_manager.load_game(slot_index):
		# Scene change is handled by SaveManager.load_game()
		hide_ui() # This UI will be gone once scene changes
	else:
		message_label.text = "Failed to load game from Slot %s." % (slot_index + 1)

func _on_delete_slot_pressed(slot_index: int):
	current_slot_for_action = slot_index
	var slot_info = save_manager.get_save_slot_info(slot_index)
	var player_name = slot_info.get("player_name", "this save file")
	delete_confirm_dialog.dialog_text = "Really delete save in Slot %s (%s)?" % [slot_index + 1, player_name]
	delete_confirm_dialog.popup_centered()

func _on_delete_confirmed():
	if current_slot_for_action != -1:
		if save_manager.delete_save(current_slot_for_action):
			message_label.text = "Save Slot %s deleted." % (current_slot_for_action + 1)
			update_slot_displays() # Refresh
		else:
			message_label.text = "Error deleting Slot %s." % (current_slot_for_action + 1)
	current_slot_for_action = -1

func _on_back_pressed():
	hide_ui()
	emit_signal("back_to_main_menu")

func _input(event: InputEvent): # Or you can rename to _unhandled_input if you prefer
	if self.visible and Input.is_action_just_pressed("ui_cancel"): # CORRECTED LINE
		print("DEBUG: load_game_ui - ui_cancel detected, calling hide_ui()")
		hide_ui()
		# It's good practice to mark the event as handled if you've processed it,
		# especially in UI, to prevent other elements from also processing it.
		get_tree().get_root().set_input_as_handled()
