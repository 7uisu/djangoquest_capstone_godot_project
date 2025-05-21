#bulletin_board.gd
extends Area2D

@export var interaction_text: String = "(F) to View Board"
@onready var interaction_label: Label = $Label
@onready var player_node = null

var player_is_inside: bool = false
var bulletin_ui_scene := preload("res://scenes/Levels/Chapter 2/bulleting_board_ui.tscn")
var bulletin_ui_instance: Control = null
var ui_layer: CanvasLayer = null # Reference to the UILayer

func _ready() -> void:
	print("[BulletinBoard] _ready()")
	if interaction_label:
		interaction_label.text = interaction_text
		interaction_label.visible = false

	# Get reference to the UILayer once when the bulletin board is ready
	# This assumes a CanvasLayer named 'UILayer' exists under '/root/Playground/'
	ui_layer = get_node_or_null("/root/Playground/UILayer")
	if not ui_layer:
		printerr("[BulletinBoard] UILayer not found at /root/Playground/UILayer. Bulletin UI might not display correctly as an overlay.")


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("is_player"):
		print("[BulletinBoard] Player entered area")
		player_is_inside = true
		player_node = body
		interaction_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.has_method("is_player"):
		print("[BulletinBoard] Player exited area")
		player_is_inside = false
		interaction_label.visible = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and player_is_inside:
		print("[BulletinBoard] Interact key pressed")
		interact()

func interact() -> void:
	print("[BulletinBoard] interact() called")
	interaction_label.visible = false

	if bulletin_ui_instance == null:
		print("[BulletinBoard] Instantiating UI")
		bulletin_ui_instance = bulletin_ui_scene.instantiate()
		
		# Add the instantiated UI to the UILayer if it exists
		if ui_layer:
			ui_layer.add_child(bulletin_ui_instance)
			print("[BulletinBoard] Added Bulletin UI to UILayer.")
		else:
			# Fallback if UILayer is not found (less ideal for UI overlays)
			get_tree().current_scene.add_child(bulletin_ui_instance)
			printerr("[BulletinBoard] UILayer not found, added Bulletin UI to current scene. It might not display correctly.")

		if bulletin_ui_instance.has_signal("closed"):
			print("[BulletinBoard] Connecting close signal")
			bulletin_ui_instance.connect("closed", Callable(self, "_on_bulletin_closed"))
	else:
		print("[BulletinBoard] UI already exists, setting visible")
		bulletin_ui_instance.visible = true

	if player_node and "can_move" in player_node:
		print("[BulletinBoard] Disabling player movement")
		player_node.can_move = false
	else:
		print("[BulletinBoard] Player node invalid or missing can_move")

	if bulletin_ui_instance:
		print("[BulletinBoard] Showing bulletin UI")
		bulletin_ui_instance.show_bulletin()
	else:
		printerr("[BulletinBoard] bulletin_ui_instance is null after instantiation!")

func _on_bulletin_closed():
	print("[BulletinBoard] Bulletin UI closed")
	if player_node and "can_move" in player_node:
		player_node.can_move = true
	if player_is_inside:
		interaction_label.visible = true
