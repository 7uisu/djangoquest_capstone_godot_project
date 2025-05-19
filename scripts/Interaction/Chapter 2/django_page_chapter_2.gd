extends Area2D

@export var interaction_text: String = "(F) to Interact"
@onready var interaction_label: Label = $Label
@export var show_once: bool = false

var has_interacted: bool = false
var currently_showing_book: bool = false
var player_is_inside: bool = false
var player_node: Node2D = null
var book_overlay_scene = preload("res://scenes/DjangoBookScenes/django_book_chapter_2.tscn")
var book_instance = null

func _ready():
	if interaction_label:
		interaction_label.text = interaction_text
		interaction_label.visible = false

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("is_player"):
		player_is_inside = true
		player_node = body
		if !currently_showing_book and (!show_once or !has_interacted):
			interaction_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.has_method("is_player"):
		player_is_inside = false
		interaction_label.visible = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and player_is_inside:
		interact()

	# If the book overlay is visible and spacebar is pressed, change scene
	if currently_showing_book and Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://scenes/Levels/Chapter 2/chapter_2_world_part_2.tscn")

func interact():
	if show_once and has_interacted and not currently_showing_book:
		return

	if interaction_label:
		interaction_label.visible = false

	currently_showing_book = true

	if book_instance == null:
		book_instance = book_overlay_scene.instantiate()
		get_tree().current_scene.add_child(book_instance)
		if book_instance.has_signal("closed"):
			book_instance.connect("closed", Callable(self, "_on_book_closed"))
	else:
		book_instance.visible = true

	if player_node:
		if book_instance is Control:
			var overlay_size = book_instance.get_rect().size
			book_instance.position = player_node.global_position - overlay_size / 2
		else:
			book_instance.global_position = player_node.global_position

		if "can_move" in player_node:
			player_node.can_move = false

	has_interacted = true

func _on_book_closed():
	currently_showing_book = false

	if player_is_inside and (not show_once or not has_interacted):
		if interaction_label:
			interaction_label.visible = true

	if player_node and "can_move" in player_node:
		player_node.can_move = true
