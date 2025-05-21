extends Area2D

@export var interaction_text: String = "(F) to Talk"
@onready var interaction_label: Label = $Label
@export var show_once: bool = false

var has_interacted: bool = false
var player_is_inside: bool = false
var player_node: Node2D = null
var dialogue_ui_path: NodePath = NodePath("/root/Playground/UILayer/BlueBotInteractionDialogue")

func _ready() -> void:
	if interaction_label:
		interaction_label.text = interaction_text
		interaction_label.visible = false

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("is_player"):
		player_is_inside = true
		player_node = body
		if !show_once or !has_interacted:
			interaction_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.has_method("is_player"):
		player_is_inside = false
		interaction_label.visible = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and player_is_inside:
		interact()

func interact() -> void:
	if show_once and has_interacted:
		return

	if interaction_label:
		interaction_label.visible = false

	var dialogue_ui = get_node_or_null(dialogue_ui_path)
	if dialogue_ui and dialogue_ui.has_method("start_dialogue"):
		dialogue_ui.start_dialogue()
		
	has_interacted = true
