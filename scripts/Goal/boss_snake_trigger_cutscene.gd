extends Area2D

func _ready():
	# Connect to the body_entered signal
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	# Check if the body that entered is the player by its name
	if body.name == "Player":
		print("Player entered boss snake trigger area")
		
		# Get the parent scene and call its method to handle the trigger
		var parent = get_parent()
		if parent and parent.has_method("_on_boss_snake_trigger_entered"):
			parent._on_boss_snake_trigger_entered()
		else:
			push_error("Parent scene doesn't have _on_boss_snake_trigger_entered method")
			# Fallback: try to change scene directly
			get_tree().change_scene_to_file("res://scenes/Levels/Chapter 1/chapter_1_world_part_3.1.tscn")
