# chapter_2_trigger_cutscene_1.gd
extends Area2D

# Export NodePaths to link nodes in the editor
@export var dialogue_4_node_path: NodePath
var dialogue_4_node: Control # Will hold Chapter2InteractionDialogue4

@export var black_tile_node_path: NodePath
var black_tile_node: Node # Can be TileMapLayer or any Node2D/CanvasItem for visibility

# @export var player_node_path: NodePath # Alternative if player isn't global
# var player_node: CharacterBody2D

@onready var player_global = get_node_or_null("/root/Playground/Player") # Assuming global player path

var has_triggered: bool = false
var original_camera_offset: Vector2 = Vector2.ZERO
var camera_moved: bool = false

# Camera movement parameters
const CAMERA_MOVE_OFFSET_Y: float = -70.0 # Move camera UP (negative Y)
const CAMERA_MOVE_DURATION: float = 0.5 # Duration for camera tween

func _ready() -> void:
	# Get actual node references from paths
	if dialogue_4_node_path:
		dialogue_4_node = get_node_or_null(dialogue_4_node_path)
	if not dialogue_4_node:
		printerr("Chapter2TriggerCutscene1: Dialogue4 node not found at path: ", dialogue_4_node_path)
	elif not dialogue_4_node.has_method("start_this_dialogue"):
		printerr("Chapter2TriggerCutscene1: Dialogue4 node does not have 'start_this_dialogue' method.")
		dialogue_4_node = null # Invalidate if unusable

	if black_tile_node_path:
		black_tile_node = get_node_or_null(black_tile_node_path)
	if not black_tile_node:
		printerr("Chapter2TriggerCutscene1: BlackTile node not found at path: ", black_tile_node_path)
	
	# Connect the signal for body entering
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if has_triggered:
		return

	# Check if the entering body is the player
	var current_player_node = player_global # or get_node_or_null(player_node_path) if using exported path
	if not current_player_node:
		printerr("Chapter2TriggerCutscene1: Player node not found.")
		return

	if body == current_player_node: # More robust check than name or group for direct player reference
		print("Player entered Chapter_2_Trigger_Cutscene_1")
		has_triggered = true
		
		# 1. Disable player movement
		current_player_node.set("can_move", false) # Assuming 'can_move' property exists on player

		# 2. Move player's Camera2D up a little
		var player_camera: Camera2D = current_player_node.get_node_or_null("Camera2D") # Adjust path if camera is named differently or nested
		if player_camera:
			original_camera_offset = player_camera.offset # Store original offset if you want to revert
			camera_moved = true
			
			var tween = get_tree().create_tween()
			tween.tween_property(player_camera, "offset:y", player_camera.offset.y + CAMERA_MOVE_OFFSET_Y, CAMERA_MOVE_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			# You might want to wait for the tween to finish before showing dialogue, or let it happen concurrently
			# await tween.finished 
		else:
			printerr("Chapter2TriggerCutscene1: Player's Camera2D not found.")

		# 3. Make BlackTile invisible
		if black_tile_node:
			if black_tile_node.has_method("hide"): # Works for CanvasItem and Node2D
				black_tile_node.hide()
			# If it's a TileMap and you want to clear cells, it's more complex.
			# For TileMapLayer, 'hide()' or 'visible = false' is usually sufficient.
			# black_tile_node.visible = false # Alternative
			print("BlackTile hidden.")
		else:
			printerr("Chapter2TriggerCutscene1: BlackTile node not configured to be hidden.")

		# 4. Activate Chapter2InteractionDialogue4
		if dialogue_4_node:
			# Optional: Pass a specific sequence key if needed for Dialogue4
			dialogue_4_node.start_this_dialogue("cutscene_reveal")
			# Connect to its finished signal to potentially revert camera or other states
			if not dialogue_4_node.is_connected("dialogue_finished", Callable(self, "_on_dialogue_4_finished")):
				dialogue_4_node.dialogue_finished.connect(_on_dialogue_4_finished, CONNECT_ONE_SHOT)
		else:
			printerr("Cannot trigger Chapter2InteractionDialogue4: Node not set or method missing.")
			# If dialogue can't start, re-enable player movement
			current_player_node.set("can_move", true)
		
		# Optional: Disable the trigger after it's used once
		# monitoring = false
		# or to remove it completely:
		# queue_free()
		set_process(false) # Stop _process if any
		set_physics_process(false) # Stop _physics_process if any
		monitoring = false # Stop detecting bodies

func _on_dialogue_4_finished() -> void:
	print("Cutscene dialogue finished. Player movement re-enabled by Dialogue4 script.")
	# Player movement is re-enabled by Dialogue4 itself.
	# If you need to revert camera position or other cutscene-specific states, do it here.
	# For example, to revert camera (optional):
	# var current_player_node = player_global
	# if current_player_node and camera_moved:
	# 	var player_camera: Camera2D = current_player_node.get_node_or_null("Camera2D")
	# 	if player_camera:
	# 		var tween = get_tree().create_tween()
	# 		tween.tween_property(player_camera, "offset", original_camera_offset, CAMERA_MOVE_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
