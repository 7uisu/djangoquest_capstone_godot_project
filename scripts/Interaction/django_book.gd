extends Area2D

@export var interaction_text: String = "(F) Examine Book"
@onready var interaction_label: Label = $Label
@export var show_once: bool = false
@export var book_title: String = "Django Book"

var has_interacted: bool = false
var currently_showing_book: bool = false
var player_is_inside: bool = false
var player_node: Node2D = null
var book_overlay_scene = preload("res://scenes/DjangoBookScenes/django_book_chapter_1.tscn")
var book_instance = null

func _ready():
	interaction_label.text = interaction_text
	interaction_label.visible = false

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("is_player"):
		player_is_inside = true
		player_node = body
		
		# Only show the label if we're not currently viewing the book
		# and (if we want to show it every time or haven't interacted yet)
		if !currently_showing_book && (!show_once || !has_interacted):
			interaction_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.has_method("is_player"):
		player_is_inside = false
		interaction_label.visible = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and player_is_inside:
		interact()

func interact():
	if show_once and has_interacted and !currently_showing_book:
		return
		
	# Hide the interaction label when the book is opened
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
		var overlay_size = book_instance.get_rect().size
		if book_instance is Control:
			book_instance.position = player_node.global_position - overlay_size / 2
		else:
			book_instance.global_position = player_node.global_position - overlay_size / 2
			
		if "can_move" in player_node:
			player_node.can_move = false
			
	has_interacted = true

func _on_book_closed():
	currently_showing_book = false
	
	# When book is closed, only show interaction label if:
	# 1. Player is still in area AND
	# 2. Either show_once is false OR has_interacted is false
	if player_is_inside && (!show_once || !has_interacted):
		interaction_label.visible = true
		
	if player_node and "can_move" in player_node:
		player_node.can_move = true
