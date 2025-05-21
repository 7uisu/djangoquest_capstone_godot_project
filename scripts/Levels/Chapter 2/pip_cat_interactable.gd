extends Area2D

@export var interaction_text: String = "(F) to Talk"
@onready var interaction_label: Label = $Label
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D # Reference to the AnimatedSprite2D
@export var show_once: bool = false

var has_interacted: bool = false
var player_is_inside: bool = false
var player_node: Node2D = null
var dialogue_ui_path: NodePath = NodePath("/root/Playground/UILayer/PipCatInteractionDialogue")

var animation_duration: float = 10.0 # Duration for each animation (10 seconds)
var current_animation_state: String = "pip_idle_right_2" # Start with this animation

func _ready() -> void:
	if interaction_label:
		interaction_label.text = interaction_text
		interaction_label.visible = false
	
	# Start the animation cycling
	start_animation_cycle()

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

func start_animation_cycle() -> void:
	if animated_sprite_2d:
		# Play the initial animation
		animated_sprite_2d.play(current_animation_state)
		
		# Create a timer to switch animations
		# The 'await' keyword pauses the function until the timeout signal is received.
		await get_tree().create_timer(animation_duration).timeout 
		
		# Ensure the node is still valid before continuing (important if the node might be freed)
		if not is_instance_valid(self):
			return

		# Switch to the other animation
		if current_animation_state == "pip_idle_right_2":
			current_animation_state = "pip_idle_right_1"
		else:
			current_animation_state = "pip_idle_right_2"
		
		# Recursively call this function to continue the cycle
		start_animation_cycle()
