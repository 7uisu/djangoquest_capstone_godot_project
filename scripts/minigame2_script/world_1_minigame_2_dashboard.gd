#world_1_minigame_2_dashboard.gd
extends Area2D

@export var interaction_text: String = "(F) Open Dashboard"
@onready var interaction_label: Label = $Label
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var show_once: bool = false
var has_interacted: bool = false
var currently_showing_dashboard: bool = false
var player_is_inside: bool = false
var player_node: Node2D = null

var dashboard_overlay_scene = preload("res://scenes/UI/world_1_minigame_2_dashboard_ui.tscn")
var dashboard_instance = null

func _ready():
	if interaction_label:
		interaction_label.text = interaction_text
		interaction_label.visible = false
	
	# Initialize animation
	if anim_sprite:
		if anim_sprite.sprite_frames != null:
			var animation_names = anim_sprite.sprite_frames.get_animation_names()
			if "default" in animation_names:
				anim_sprite.play("default")
			else:
				print("Error: No 'default' animation found.")

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("is_player"):
		player_is_inside = true
		player_node = body
		
		# Only show the label if we're not currently viewing the dashboard
		# and (if we want to show it every time or haven't interacted yet)
		if !currently_showing_dashboard && (!show_once || !has_interacted):
			if interaction_label:
				interaction_label.visible = true
		
		if anim_sprite and anim_sprite.sprite_frames != null:
			var animation_names = anim_sprite.sprite_frames.get_animation_names()
			if "interact" in animation_names:
				anim_sprite.play("interact")

func _on_body_exited(body: Node2D) -> void:
	if body.has_method("is_player"):
		player_is_inside = false
		player_node = null
		
		if interaction_label:
			interaction_label.visible = false
		
		if anim_sprite and anim_sprite.sprite_frames != null:
			var animation_names = anim_sprite.sprite_frames.get_animation_names()
			if "default" in animation_names:
				anim_sprite.play("default")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and player_is_inside and !currently_showing_dashboard:
		interact()

func interact():
	if show_once and has_interacted and !currently_showing_dashboard:
		return
		
	print("You have interacted with the Minigame2Dashboard")
	
	# Hide the interaction label when the dashboard is opened
	if interaction_label:
		interaction_label.visible = false
	
	currently_showing_dashboard = true
	
	# Instantiate the dashboard UI and add it to the UI layer for proper positioning
	if dashboard_instance == null:
		dashboard_instance = dashboard_overlay_scene.instantiate()
		
		# Add to the CanvasLayer if it exists, otherwise add to the scene root
		var ui_layer = get_tree().get_root().get_node_or_null("UILayer")
		if ui_layer == null:
			# If no dedicated UI layer exists, we'll create a CanvasLayer for proper positioning
			var canvas_layer = CanvasLayer.new()
			canvas_layer.name = "DashboardLayer"
			canvas_layer.layer = 10  # Higher layer to be on top of game elements
			get_tree().current_scene.add_child(canvas_layer)
			canvas_layer.add_child(dashboard_instance)
		else:
			ui_layer.add_child(dashboard_instance)
			
		if dashboard_instance.has_signal("closed"):
			dashboard_instance.connect("closed", Callable(self, "_on_dashboard_closed"))
	else:
		dashboard_instance.visible = true
	
	# Ensure the dashboard is properly centered regardless of its parent
	if dashboard_instance is Control:
		# Get the viewport size to center it on screen
		var viewport_rect = get_viewport_rect()
		dashboard_instance.position = Vector2.ZERO
		dashboard_instance.anchor_left = 0.5
		dashboard_instance.anchor_top = 0.5
		dashboard_instance.anchor_right = 0.5
		dashboard_instance.anchor_bottom = 0.5
		dashboard_instance.offset_left = -dashboard_instance.size.x / 2
		dashboard_instance.offset_top = -dashboard_instance.size.y / 2
		dashboard_instance.offset_right = dashboard_instance.size.x / 2
		dashboard_instance.offset_bottom = dashboard_instance.size.y / 2
		
	# Call the show_dashboard method if available
	if dashboard_instance.has_method("show_dashboard"):
		dashboard_instance.show_dashboard()
	else:
		dashboard_instance.visible = true
		
	# Disable player movement if possible
	if player_node and "can_move" in player_node:
		player_node.can_move = false
		
	has_interacted = true

func _on_dashboard_closed():
	currently_showing_dashboard = false
	
	# When dashboard is closed, only show interaction label if:
	# 1. Player is still in area AND
	# 2. Either show_once is false OR has_interacted is false
	if player_is_inside && (!show_once || !has_interacted):
		if interaction_label:
			interaction_label.visible = true
	
	# Re-enable player movement
	if player_node and "can_move" in player_node:
		player_node.can_move = true
