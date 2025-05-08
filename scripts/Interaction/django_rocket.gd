extends Node

@export var interaction_text: String = "(F) Get into Rocket"
@onready var interaction_label: Label = $Label
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var show_once: bool = false
var has_interacted: bool = false
var player_is_inside: bool = false
var is_interacting: bool = false  # Flag to prevent double interactions

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("is_player"):
		player_is_inside = true
		if interaction_label:
			interaction_label.visible = true
			interaction_label.text = interaction_text
		if anim_sprite and anim_sprite.sprite_frames != null:
			var animation_names = anim_sprite.sprite_frames.get_animation_names()
			if "interact" in animation_names:
				anim_sprite.play("interact")
			elif "default" in animation_names:
				anim_sprite.play("default")
			else:
				print("Error: Neither 'interact' nor 'default' animation found.")

func _on_body_exited(body: Node2D) -> void:
	if body.has_method("is_player"):
		player_is_inside = false
		if interaction_label:
			interaction_label.visible = false
		if anim_sprite and anim_sprite.sprite_frames != null:
			var animation_names = anim_sprite.sprite_frames.get_animation_names()
			if "default" in animation_names:
				anim_sprite.play("default")

func _ready():
	if interaction_label:
		interaction_label.text = interaction_text
		interaction_label.visible = false
	
	if anim_sprite and anim_sprite.sprite_frames != null:
		var animation_names = anim_sprite.sprite_frames.get_animation_names()
		if "default" in animation_names:
			anim_sprite.play("default")
		else:
			print("Error: No 'default' animation found.")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and player_is_inside and !is_interacting:
		interact()

func interact():
	if show_once and has_interacted:
		return
	
	# Set flag to prevent multiple interactions
	is_interacting = true
	has_interacted = true
	
	# Change scene instead of printing
	get_tree().change_scene_to_file("res://scenes/Levels/Chapter 1/chapter_1_world_part_4_rocket_interior.tscn")
