# books_minigame_dashboard.gd
extends Area2D

@export var interaction_text: String = "(F) Open Book" # Or "(F) Open Books & Minigames"
@export var default_text: String = "Books & Minigames"  # Or "Access Books & Minigames"
@export var books_and_minigame_ui: PackedScene # Assign in Inspector

@onready var interaction_label: Label = $Label

var player_is_inside: bool = false
var ui_instance = null # Store the instanced UI
var ui_layer_node

func _ready():
	if interaction_label:
		interaction_label.text = default_text
		interaction_label.visible = true

	if not books_and_minigame_ui:
		printerr("BooksMinigameDashboard: books_and_minigame_ui scene not assigned in Inspector!") # Changed here

	# Attempt to find UILayer.
	if get_tree().current_scene:
		ui_layer_node = get_tree().current_scene.find_child("UILayer", true, false)
		if not ui_layer_node:
			printerr("BooksMinigameDashboard: Could not find 'UILayer' in the current scene. UI will be added to root.") # Changed here
	else:
		printerr("BooksMinigameDashboard: Current scene not available at _ready(). UILayer not found yet.") # Changed here


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

func _unhandled_input(event: InputEvent):
	if player_is_inside and Input.is_action_just_pressed("interact"):
		var ui_is_open_and_valid = ui_instance and is_instance_valid(ui_instance) and ui_instance.is_visible_in_tree()

		if not ui_is_open_and_valid:
			interact()
		elif ui_is_open_and_valid and ui_instance.has_method("show_ui"):
			print("Books & Minigame UI is already open or interaction is being handled.") # Changed here
			ui_instance.show_ui()

		get_tree().get_root().set_input_as_handled()


func interact():
	if not books_and_minigame_ui:
		print("BooksMinigameDashboard: UI scene (books_and_minigame_ui) not set.") # Changed here
		return

	if not ui_layer_node and get_tree().current_scene:
		ui_layer_node = get_tree().current_scene.find_child("UILayer", true, false)

	if not ui_instance or not is_instance_valid(ui_instance):
		ui_instance = books_and_minigame_ui.instantiate()
		if ui_layer_node:
			ui_layer_node.add_child(ui_instance)
		else:
			get_tree().root.add_child(ui_instance) # Fallback
			printerr("BooksMinigameDashboard: Added UI to tree root as UILayer was not found during interact.") # Changed here

	if ui_instance and ui_instance.has_method("show_ui"):
		ui_instance.show_ui()
		print("You have interacted with the Books & Minigame Dashboard - UI shown.") # Changed here
	else:
		printerr("BooksMinigameDashboard: Failed to instance or show UI (books_and_minigame_ui).") # Changed here
