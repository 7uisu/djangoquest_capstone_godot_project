#save_dashboard.gd
extends Area2D

@export var interaction_text: String = "(F) Save Game"
@onready var interaction_label: Label = $Label
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var show_once: bool = false

var has_interacted: bool = false
var player_is_inside: bool = false

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("is_player"):
		player_is_inside = true
		if interaction_label:
			interaction_label.visible = true
			interaction_label.text = interaction_text
		if anim_sprite:
			if anim_sprite.sprite_frames != null:
				var animation_names = anim_sprite.sprite_frames.get_animation_names()
				if "interact" in animation_names:
					anim_sprite.play("interact")
				elif "default" in animation_names:
					anim_sprite.play("default") # Added this to play default if interact doesn't exist.
				else:
					print("Error: Neither 'interact' nor 'default' animation found.")

func _on_body_exited(body: Node2D) -> void:
	if body.has_method("is_player"):
		player_is_inside = false
		if interaction_label:
			interaction_label.visible = false
		if anim_sprite:
			if anim_sprite.sprite_frames != null:
				var animation_names = anim_sprite.sprite_frames.get_animation_names()
				if "default" in animation_names:
					anim_sprite.play("default")

func _ready():
	if interaction_label:
		interaction_label.text = interaction_text
		interaction_label.visible = false
	if anim_sprite:
		if anim_sprite.sprite_frames != null:
			var animation_names = anim_sprite.sprite_frames.get_animation_names()
			if "interact" in animation_names:
				anim_sprite.play("interact")
			elif "default" in animation_names: # added this
				anim_sprite.play("default")
			else:
				print("Error:  Neither 'interact' nor 'default' animation found.")

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and player_is_inside:
		interact()

func interact():
	if show_once and has_interacted:
		return

	print("You have interacted with the Save Dashboard")
	has_interacted = true
