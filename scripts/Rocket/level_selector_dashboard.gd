#level_selector_dashboard.gd
extends Area2D

@export var interaction_text: String = "(F) Select Level"
@export var default_text: String = "Select Level Here"
@export var level_selector_ui_scene: PackedScene # Assign in Inspector

@onready var interaction_label: Label = $Label

var player_is_inside: bool = false
var ui_instance = null # Store the instanced UI
var ui_layer_node

func _ready():
	if interaction_label:
		interaction_label.text = default_text
		interaction_label.visible = true

	if not level_selector_ui_scene:
		printerr("LevelSelectorDashboard: level_selector_ui_scene not assigned in Inspector!")

	# Attempt to find UILayer.
	# This assumes hub_area is the current scene when this dashboard is ready.
	# Ensure UILayer exists in your hub_area.tscn for the UI to be parented correctly.
	if get_tree().current_scene:
		ui_layer_node = get_tree().current_scene.find_child("UILayer", true, false)
		if not ui_layer_node:
			printerr("LevelSelectorDashboard: Could not find 'UILayer' in the current scene. UI will be added to root.")
	else:
		printerr("LevelSelectorDashboard: Current scene not available at _ready(). UILayer not found yet.")


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("is_player"):
		player_is_inside = true
		if interaction_label:
			interaction_label.text = interaction_text

func _on_body_exited(body: Node2D) -> void:
	if body.has_method("is_player"):
		player_is_inside = false
		if interaction_label:
			interaction_label.text = default_text

# MODIFIED FUNCTION:
func _unhandled_input(event: InputEvent):
	# We check the global Input singleton for the action state.
	# The 'event' parameter is still required by _unhandled_input, but we don't use it directly for this check.
	if player_is_inside and Input.is_action_just_pressed("interact"):
		# If the UI instance exists, is valid, and is visible, maybe we want to close it or toggle it.
		# For now, let's assume pressing "interact" again while it's open does nothing or re-opens if somehow closed.
		var ui_is_open_and_valid = ui_instance and is_instance_valid(ui_instance) and ui_instance.is_visible_in_tree()

		if not ui_is_open_and_valid: # Only interact if UI is not already open and valid
			interact()
		elif ui_is_open_and_valid and ui_instance.has_method("show_ui"):
			# If it was somehow hidden but still valid, re-show it.
			# Or, if you want "interact" to toggle, you'd add hide_ui() logic here.
			# For now, we'll assume interact only opens or re-focuses.
			print("Level Selector UI is already open or interaction is being handled.")
			ui_instance.show_ui() # Ensures it's focused and data is up-to-date

		# Consume the event if we handled it to prevent other nodes from processing it.
		# This is important if multiple things could react to "interact".
		get_tree().get_root().set_input_as_handled()


func interact():
	if not level_selector_ui_scene:
		print("Level Selector Dashboard: UI scene not set.")
		return

	# Ensure ui_layer_node is found if it wasn't in _ready (e.g., scene was still loading)
	if not ui_layer_node and get_tree().current_scene:
		ui_layer_node = get_tree().current_scene.find_child("UILayer", true, false)

	if not ui_instance or not is_instance_valid(ui_instance):
		ui_instance = level_selector_ui_scene.instantiate()
		if ui_layer_node:
			ui_layer_node.add_child(ui_instance)
		else:
			get_tree().root.add_child(ui_instance) # Fallback
			printerr("LevelSelectorDashboard: Added UI to tree root as UILayer was not found during interact.")

	if ui_instance and ui_instance.has_method("show_ui"):
		ui_instance.show_ui()
		print("You have interacted with the Level Selector Dashboard - UI shown.")
	else:
		printerr("Level Selector Dashboard: Failed to instance or show UI.")
