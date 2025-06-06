#rocket_terminal.gd
extends Area2D

@export var interaction_text: String = "(F) Use Terminal"
@export var show_once: bool = false
@onready var interaction_label: Label = $Label
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ui_control = get_node("/root/chapter_1_world_part_3_2nd_minigame/MinigameManager/UILayer/RocketTerminalUI")

var has_interacted: bool = false
var player_is_inside: bool = false
var interact_key_pressed: bool = false  # Track if the interact key was pressed

func _ready():
	# Setup interaction label
	interaction_label.text = interaction_text
	interaction_label.visible = false
	
	# Play default animation if it exists
	if animated_sprite.sprite_frames.has_animation("default"):
		animated_sprite.play("default")
	else:
		print("No 'default' animation found in SpriteFrames")
	
	# Hide UI at start
	if ui_control:
		ui_control.visible = false
	else:
		# Fallback: try to find UI node if not found initially
		ui_control = get_tree().get_root().find_child("RocketTerminalUI", true, false)
		if ui_control:
			ui_control.visible = false
			print("[ROCKET_TERMINAL] UI found by search and hidden")
	
	# Connect signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

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
		# Set the flag to indicate interaction key was pressed
		interact_key_pressed = true
		# Call interact with a slight delay to consume the input
		call_deferred("interact")

func interact():
	if show_once and has_interacted:
		return
	
	print("You interact with the terminal.")
	has_interacted = true
	
	# === Show UI ===
	if ui_control:
		ui_control.visible = true
		print("[ROCKET_TERMINAL] Showing terminal UI")
		
		# Temporarily consume input to prevent 'f' from appearing in LineEdit
		if interact_key_pressed:
			# Reset the flag
			interact_key_pressed = false
			# Block "f" from being typed
			get_viewport().set_input_as_handled()
			
		# Optional: update the boss state if the method exists
		if ui_control.has_method("update_boss_state"):
			ui_control.update_boss_state()
			
		# Focus on LineEdit with a slight delay to avoid capturing 'f'
		var line_edit = ui_control.get_node_or_null("LineEdit")
		if line_edit:
			# Use a timer to delay focusing to avoid capturing 'f'
			var focus_timer = Timer.new()
			focus_timer.wait_time = 0.05  # 50ms delay
			focus_timer.one_shot = true
			add_child(focus_timer)
			focus_timer.timeout.connect(func():
				line_edit.grab_focus()
				# Clear any text that might have been added
				line_edit.clear()
				print("[ROCKET_TERMINAL] Focus set to line edit")
			)
			focus_timer.start()
	else:
		print("[ROCKET_TERMINAL] ERROR: UI reference missing")
