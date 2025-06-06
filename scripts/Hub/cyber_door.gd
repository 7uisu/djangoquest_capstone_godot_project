extends Area2D

@export var interaction_text: String = "(F) Main Menu"
@export var default_text: String = "Exit"
@onready var interaction_label: Label = $Label
@onready var confirmation_dialogue = $"../UILayer/ToMainMenuConfirmationDialog" # Path to your ConfirmationDialog

@export var show_once: bool = false
var has_interacted: bool = false
var player_is_inside: bool = false
var player_node: Node2D = null # Variable to store the player node

func _ready():
	# Connect Area2D signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	if interaction_label:
		interaction_label.text = default_text
		interaction_label.visible = true # Always show the label
	
	# Connect to confirmation dialogue signals if it exists
	if confirmation_dialogue:
		# Connect the confirmation and cancel signals
		if confirmation_dialogue.has_signal("confirmed"):
			confirmation_dialogue.confirmed.connect(_on_to_main_menu_confirmation_dialog_confirmed)
		# For Godot 4, the signal is 'canceled'. For Godot 3, it might be 'popup_hide' or custom.
		# Assuming 'canceled' is the correct signal for your dialog's cancel action.
		if confirmation_dialogue.has_signal("canceled"): # Godot 4
			confirmation_dialogue.canceled.connect(_on_to_main_menu_confirmation_dialog_canceled)
		elif confirmation_dialogue.has_signal("popup_hide") and not confirmation_dialogue.has_signal("canceled"): # Godot 3 fallback for some dialogs
			# This might also trigger on confirm, so careful logic would be needed if using this.
			# For a standard ConfirmationDialog, 'confirmed' and simply closing/hiding it on cancel is typical.
			# The user's original script implies a 'canceled' signal exists, so this is likely a fallback.
			pass
	else:
		printerr("CyberDoor: Confirmation dialogue node not found at path: ", get_path_to(confirmation_dialogue))


func _on_body_entered(body: Node2D) -> void:
	# Check if the body is the player (assuming player has a method "is_player" or a specific group/class_name)
	if body.has_method("is_player"): # Or use groups: if body.is_in_group("player"):
		player_is_inside = true
		player_node = body # Store the player node reference
		if interaction_label:
			interaction_label.text = interaction_text

func _on_body_exited(body: Node2D) -> void:
	if body.has_method("is_player"): # Or use groups: if body.is_in_group("player"):
		player_is_inside = false
		if interaction_label:
			interaction_label.text = default_text
		if body == player_node: # If the exiting body is the stored player
			player_node = null # Clear the player node reference

func _unhandled_input(event: InputEvent):
	if player_is_inside and Input.is_action_just_pressed("interact"):
		var dialogue_is_open = confirmation_dialogue and is_instance_valid(confirmation_dialogue) and confirmation_dialogue.visible
		if not dialogue_is_open:
			interact()
		else:
			print("Confirmation dialogue is already open.")
		get_tree().get_root().set_input_as_handled() # Mark input as handled

func interact():
	if show_once and has_interacted:
		return
	
	print("Player interacted. Opening main menu confirmation dialogue.")
	has_interacted = true # Mark as interacted
	
	# Show the confirmation dialogue
	if confirmation_dialogue:
		# Disable player movement
		if player_node and "can_move" in player_node:
			print("Disabling player movement.")
			player_node.set("can_move", false)
		else:
			if not player_node:
				printerr("CyberDoor: Player node not found when trying to disable movement.")
			elif not ("can_move" in player_node):
				printerr("CyberDoor: Player node does not have 'can_move' property.")

		# Check if the dialog node is valid before trying to show it
		if is_instance_valid(confirmation_dialogue):
			confirmation_dialogue.visible = true
			# If it's a popup type dialog, calling popup() or popup_centered() is often better.
			if confirmation_dialogue.has_method("popup_centered"):
				confirmation_dialogue.popup_centered()
			elif confirmation_dialogue.has_method("popup"):
				confirmation_dialogue.popup()
		else:
			printerr("CyberDoor: Confirmation dialogue instance is not valid before showing!")
			# Re-enable player movement if dialog cannot be shown
			if player_node and "can_move" in player_node:
				player_node.set("can_move", true)

	else:
		printerr("CyberDoor: Confirmation dialogue not found when trying to interact!")
		# No dialog, so ensure has_interacted is reset if show_once is false, or handle accordingly
		if not show_once:
			has_interacted = false 

func _on_to_main_menu_confirmation_dialog_confirmed() -> void:
	print("Confirmed - Going to main menu")
	# Player movement will implicitly be handled by the scene change.
	# No need to re-enable movement here as the player object might be freed.
	get_tree().change_scene_to_file("res://scenes/UI/main_menu_ui.tscn")

func _on_to_main_menu_confirmation_dialog_canceled() -> void:
	print("Canceled - Closing dialogue.")
	# Re-enable player movement
	if player_node and "can_move" in player_node:
		print("Re-enabling player movement.")
		player_node.set("can_move", true)
	else:
		if not player_node:
			print("CyberDoor: Player node not found when trying to re-enable movement on cancel.")
		elif not ("can_move" in player_node):
			print("CyberDoor: Player node does not have 'can_move' property on cancel.")
	
	# Ensure the dialogue is hidden if it doesn't hide itself automatically.
	# Standard ConfirmationDialogs usually hide themselves on cancel.
	if confirmation_dialogue and is_instance_valid(confirmation_dialogue) and confirmation_dialogue.visible:
		# confirmation_dialogue.visible = false # Usually not needed if dialog handles its own closure
		pass
	
	# If show_once is true, has_interacted remains true.
	# If you want the player to be able to interact again after canceling (and show_once is false),
	# you might reset has_interacted here.
	if not show_once:
		has_interacted = false
