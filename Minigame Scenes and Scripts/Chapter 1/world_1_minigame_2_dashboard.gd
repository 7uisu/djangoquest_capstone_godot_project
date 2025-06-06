#world_1_minigame_2_dashboard.gd
extends Area2D

@export var interaction_text: String = "(F) Open Dashboard"
@export var idle_text: String = "Input Last Code Here"
@onready var interaction_label: Label = $Label
@onready var sprite: Sprite2D = $Sprite2D
@export var show_once: bool = false

var has_interacted: bool = false
var currently_showing_dashboard: bool = false
var player_is_inside: bool = false
var player_node: Node2D = null

var dashboard_overlay_scene = preload("res://Minigame Scenes and Scripts/Chapter 1/world_1_minigame_2_dashboard_ui.tscn")
var dashboard_instance = null

func _ready():
	if interaction_label:
		interaction_label.text = idle_text
		interaction_label.visible = true

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("is_player"):
		player_is_inside = true
		player_node = body
		
		if !currently_showing_dashboard && (!show_once || !has_interacted):
			if interaction_label:
				interaction_label.text = interaction_text

func _on_body_exited(body: Node2D) -> void:
	if body.has_method("is_player"):
		player_is_inside = false
		player_node = null

		if interaction_label:
			interaction_label.text = idle_text

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and player_is_inside and !currently_showing_dashboard:
		interact()

func interact():
	if show_once and has_interacted and !currently_showing_dashboard:
		return
		
	print("You have interacted with the Minigame2Dashboard")
	
	if interaction_label:
		interaction_label.visible = false
	
	currently_showing_dashboard = true
	
	if dashboard_instance == null:
		dashboard_instance = dashboard_overlay_scene.instantiate()
		
		var ui_layer = get_tree().get_root().get_node_or_null("UILayer")
		if ui_layer == null:
			var canvas_layer = CanvasLayer.new()
			canvas_layer.name = "DashboardLayer"
			canvas_layer.layer = 10
			get_tree().current_scene.add_child(canvas_layer)
			canvas_layer.add_child(dashboard_instance)
		else:
			ui_layer.add_child(dashboard_instance)
			
		if dashboard_instance.has_signal("closed"):
			dashboard_instance.connect("closed", Callable(self, "_on_dashboard_closed"))
	else:
		dashboard_instance.visible = true
	
	if dashboard_instance is Control:
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
		
	if dashboard_instance.has_method("show_dashboard"):
		dashboard_instance.show_dashboard()
	else:
		dashboard_instance.visible = true
		
	if player_node and "can_move" in player_node:
		player_node.can_move = false
		
	has_interacted = true

func _on_dashboard_closed():
	currently_showing_dashboard = false
	
	if player_is_inside and (!show_once or !has_interacted):
		if interaction_label:
			interaction_label.text = interaction_text
	
	if player_node and "can_move" in player_node:
		player_node.can_move = true
