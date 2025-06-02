extends Area2D

# Add this signal to communicate with the main world script
signal interacted_with()

@export var interaction_text: String = "(F) to Interact"
@onready var interaction_label: Label = $Label
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var show_once: bool = false
var has_interacted: bool = false
var player_is_inside: bool = false

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("is_player"):
		player_is_inside = true
		
		# Only show interaction prompt if we haven't interacted yet
		if not has_interacted and interaction_label:
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

func _process(delta: float) -> void:
	# Only allow interaction if we haven't interacted yet
	if Input.is_action_just_pressed("interact") and player_is_inside and not has_interacted:
		interact()

func interact():
	if has_interacted:
		print("CuteBot has already been interacted with")
		return
	
	print("You have interacted with the CuteBot")
	has_interacted = true
	
	# Hide the interaction label since we can't interact anymore
	if interaction_label:
		interaction_label.visible = false
	
	# Emit the signal to notify the main world script
	interacted_with.emit()
