extends Control

@onready var book_sprite = $DjangoBookSprite
@onready var book_pages = $DjangoBookPages
var is_book_open = false
var interaction_dialogue_scene = preload("res://scenes/Player/interaction_dialogue.tscn")
var dialogue_active = false
var scene_change_pending = false
var player = null

func _ready():
	process_mode = Node.PROCESS_MODE_INHERIT  # not paused
	book_pages.visible = false
	book_sprite.visible = true

	# Try to find player in scene
	player = get_tree().get_first_node_in_group("player")
	if player:
		player.can_move = false  # Disable movement while book is open

func _process(_delta):
	if scene_change_pending:
		scene_change_pending = false
		print("Changing scene now")
		get_tree().change_scene_to_file("res://scenes/Levels/Chapter 1/chapter_1_world_part_2.tscn")

func _input(event):
	if event.is_action_pressed("ui_accept") and not dialogue_active:
		if not is_book_open:
			book_sprite.visible = false
			book_pages.visible = true
			is_book_open = true
		else:
			show_dialogue()

func show_dialogue():
	dialogue_active = true
	visible = false

	var ui_layer = get_parent()
	for child in ui_layer.get_children():
		if child.name == "InteractionDialogue" or child.is_in_group("dialogue"):
			child.queue_free()

	var dialogue_instance = interaction_dialogue_scene.instantiate()
	dialogue_instance.name = "InteractionDialogue"
	dialogue_instance.add_to_group("dialogue")
	ui_layer.add_child(dialogue_instance)

	dialogue_instance.connect("dialogue_finished", _on_dialogue_finished)
	dialogue_instance.start_dialogue("pip_django_explanation")

	print("Dialogue started")

func _on_dialogue_finished():
	print("Dialogue finished signal received!")
	dialogue_active = false
	scene_change_pending = true

	# Allow the player to move again
	if player:
		player.can_move = true
