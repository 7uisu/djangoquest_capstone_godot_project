# computer_chapter_3.gd
extends Area2D

@export var interaction_text: String = "(F) to Interact"
@onready var interaction_label: Label = $Label
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var show_once: bool = false

var has_interacted: bool = false
var player_is_inside: bool = false
var is_counting_down: bool = false

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
					anim_sprite.play("default")
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
			elif "default" in animation_names:
				anim_sprite.play("default")
			else:
				print("Error: Neither 'interact' nor 'default' animation found.")

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and player_is_inside and not is_counting_down:
		interact()

func interact():
	if show_once and has_interacted:
		return
	
	print("You have interacted with the computer")
	has_interacted = true
	is_counting_down = true
	
	# Hide interaction label
	if interaction_label:
		interaction_label.visible = false
	
	# Start countdown sequence
	start_countdown()

func start_countdown():
	# Get reference to GuideInstructions label
	var guide_instructions = get_node("../UILayer/GuideInstructions")
	if guide_instructions == null:
		print("Error: GuideInstructions not found")
		return
	
	var guide_label = guide_instructions.get_node("Label")
	if guide_label == null:
		print("Error: GuideInstructions Label not found")
		return
	
	# Make sure GuideInstructions is visible
	guide_instructions.visible = true
	
	# Start countdown from 3
	for i in range(3, 0, -1):
		guide_label.text = "Starting task in " + str(i) + "-"
		await get_tree().create_timer(1.0).timeout
	
	# Change to the minigame scene
	get_tree().change_scene_to_file("res://scenes/Levels/Chapter 3 (5-24-25)/Vari and Table assign minigame test/control.tscn")
