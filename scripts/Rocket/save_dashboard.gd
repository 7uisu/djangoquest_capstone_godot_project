#save_dashboard.gd
extends Area2D

@export var interaction_text: String = "(F) Save Game"
@export var default_text: String = "Save Game Here"
@export var save_game_ui_scene: PackedScene # Assign in Inspector

@onready var interaction_label: Label = $Label

var player_is_inside: bool = false
var ui_instance = null
var ui_layer_node

func _ready():
	if interaction_label:
		interaction_label.text = default_text
		interaction_label.visible = true
	if not save_game_ui_scene:
		printerr("SaveDashboard: save_game_ui_scene not assigned in Inspector!")

	if get_tree().current_scene:
		ui_layer_node = get_tree().current_scene.find_child("UILayer", true, false)
		if not ui_layer_node:
			printerr("SaveDashboard: Could not find 'UILayer' in the current scene. UI will be added to root.")
	else:
		printerr("SaveDashboard: Current scene not available at _ready(). UILayer not found yet.")


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
	if player_is_inside and Input.is_action_just_pressed("interact"):
		var ui_is_open_and_valid = ui_instance and is_instance_valid(ui_instance) and ui_instance.is_visible_in_tree()

		if not ui_is_open_and_valid:
			interact()
		elif ui_is_open_and_valid and ui_instance.has_method("show_ui"):
			print("Save Game UI is already open or interaction is being handled.")
			ui_instance.show_ui() # Re-focus/refresh

		get_tree().get_root().set_input_as_handled()

func interact():
	if not save_game_ui_scene:
		print("Save Dashboard: UI scene not set.")
		return

	if not ui_layer_node and get_tree().current_scene: # Retry finding UILayer
		ui_layer_node = get_tree().current_scene.find_child("UILayer", true, false)

	if not ui_instance or not is_instance_valid(ui_instance):
		ui_instance = save_game_ui_scene.instantiate()
		if ui_layer_node:
			ui_layer_node.add_child(ui_instance)
		else:
			get_tree().root.add_child(ui_instance) # Fallback
			printerr("SaveDashboard: Added UI to tree root as UILayer was not found during interact.")


	if ui_instance and ui_instance.has_method("show_ui"):
		ui_instance.show_ui()
		print("You have interacted with the Save Dashboard - UI shown.")
	else:
		printerr("Save Dashboard: Failed to instance or show UI.")
