# found_chapter_2_trigger.gd
extends Area2D

# Export a NodePath to link the dialogue UI in the editor
@export var found_chapter_dialogue_node_path: NodePath
var found_chapter_dialogue: Control # Will hold the actual node reference

var has_triggered: bool = false # Prevent re-triggering

func _ready() -> void:
	# Get the actual node reference from the path
	if found_chapter_dialogue_node_path:
		found_chapter_dialogue = get_node_or_null(found_chapter_dialogue_node_path)
	
	if not found_chapter_dialogue:
		printerr("FoundChapter2Trigger: Dialogue node not found at path: ", found_chapter_dialogue_node_path)
	elif not found_chapter_dialogue.has_method("start_this_dialogue"):
		printerr("FoundChapter2Trigger: Dialogue node does not have 'start_this_dialogue' method.")
		found_chapter_dialogue = null # Invalidate if unusable

	# Connect the signal for body entering
	body_entered.connect(_on_body_entered)
	
	# Optional: Set collision layers/masks if not done in editor
	# collision_layer = 0 # This trigger doesn't need to BE collided with by others
	# collision_mask = X # Set to the layer the Player is on (e.g., 1 if player is on layer 1)

func _on_body_entered(body: Node2D) -> void:
	if has_triggered:
		return

	# Check if the entering body is the player
	# Adjust this check based on how you identify your player (group, name, method)
	if body.is_in_group("player") or "Player" in body.name: # Common ways to check
		print("Player entered FoundChapter2Trigger")
		
		if found_chapter_dialogue and found_chapter_dialogue.has_method("start_this_dialogue"):
			# Optional: Pass a specific sequence key if needed
			# found_chapter_dialogue.start_this_dialogue("found_it") 
			found_chapter_dialogue.start_this_dialogue() # Starts with its default or first sequence

			has_triggered = true # Mark as triggered
			
			# Optional: Disable the trigger after it's used once
			# monitoring = false 
			# or
			# set_deferred("monitoring", false)
			# or to remove it completely:
			# queue_free()
		else:
			printerr("Cannot trigger FoundChapter2Dialogue: Node not set or method missing.")
