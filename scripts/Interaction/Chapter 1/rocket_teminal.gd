extends Area2D

@export var interaction_text: String = "(F) Use Terminal"
@onready var interaction_label: Label = $Label
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var show_once: bool = false # added show_once

var has_interacted: bool = false
var player_is_inside: bool = false

func _ready():
	interaction_label.text = interaction_text
	interaction_label.visible = false
	# Make sure "default" animation exists in the SpriteFrames
	if animated_sprite.sprite_frames.has_animation("default"):
		animated_sprite.play("default")
	else:
		print("No 'default' animation found in SpriteFrames")

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("is_player"):
		player_is_inside = true
		interaction_label.visible = true
		if animated_sprite:
			if animated_sprite.sprite_frames.has_animation("interact"):
				animated_sprite.play("interact")
			else:
				animated_sprite.play("default")

func _on_body_exited(body: Node2D) -> void:
	if body.has_method("is_player"):
		player_is_inside = false
		interaction_label.visible = false
		if animated_sprite:
			animated_sprite.play("default")

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and player_is_inside:
		interact()

func interact():
	if show_once and has_interacted:
		return
	print("You interact with the terminal.")
	# Add code here to open the terminal interface (e.g., a popup, a scene change).
	has_interacted = true
	# Example:
	# get_node("/root/GameScene/TerminalInterface").show()
