#django_pages.gd
extends Area2D

@export var interaction_text: String = "(F) Grab Page"
@export var page_title: String = "Untitled Page"
@export var command_text: String = "python -m venv djangoquest_env"
@export var page_number: int = 1  # To track the order
@export var show_once: bool = true  # Default to true for collectibles

@onready var interaction_label: Label = $Label

var has_interacted: bool = false
var player_is_inside: bool = false

func _ready():
	interaction_label.text = interaction_text
	interaction_label.visible = false
	add_to_group("collectible")

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("is_player"):
		player_is_inside = true
		interaction_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.has_method("is_player"):
		player_is_inside = false
		interaction_label.visible = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and player_is_inside:
		interact()

func interact():
	if show_once and has_interacted:
		return
		
	# Add page to global collection
	var tutorial_manager = get_node("/root/TutorialManager")
	if tutorial_manager:
		tutorial_manager.collect_page(page_number, page_title, command_text)
	
	print("You collected the page: " + page_title + " - " + command_text)
	has_interacted = true
	
	# Optional: Hide or remove the page after collection
	if show_once:
		interaction_label.visible = false
		# You could add an animation here
		# Then either hide or remove the page
		visible = false  # or queue_free() to remove completely

func reset():
	has_interacted = false
	show()  # Better than visible = true, as it ensures rendering and input
	interaction_label.visible = player_is_inside  # Show label if player is near
