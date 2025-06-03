extends Area2D

# Define the signal - this must be at the top level of the class
signal interacted_with

@export var interaction_text: String = "(F) to Interact"
@onready var interaction_label: Label = $Label
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var show_once: bool = false
var has_interacted: bool = false
var player_is_inside: bool = false

func _ready():
	# Connect the Area2D signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
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

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and player_is_inside:
		interact()

func interact():
	if show_once and has_interacted:
		return
	
	print("You have interacted with the CuteBot")
	has_interacted = true
	
	# Emit the signal - this is what the main script is listening for
	interacted_with.emit()
	print("[CuteBotInteractable] Emitted interacted_with signal")
