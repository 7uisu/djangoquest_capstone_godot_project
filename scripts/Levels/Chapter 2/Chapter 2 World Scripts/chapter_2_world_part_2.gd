extends Node2D

@onready var player = $Player
@onready var camera = player.get_node("Camera2D")
@onready var dialogue_2 = $UILayer/Chapter2InteractionDialogue2

var shaking: bool = false
var shake_duration: float = 3.0
var shake_elapsed: float = 0.0
var shake_intensity: float = 6.0

func _ready():
	# Ensure dialogue_2 was found
	if dialogue_2 == null:
		push_error("Error: dialogue_2 node not found at path $UILayer/Chapter2InteractionDialogue2")
		# Consider stopping shake or handling error if dialogue node is missing
	else:
		# Start shaking immediately
		shaking = true
		shake_elapsed = 0.0

		# Hide dialogue at start
		dialogue_2.visible = false

		# Connect dialogue finished signal
		# Connecting directly, assuming success based on previous debug
		dialogue_2.dialogue_finished.connect(_on_dialogue_finished)


func _process(delta):
	if shaking:
		shake_elapsed += delta
		# Apply random shake offset
		camera.offset = Vector2(
			randfn(0, shake_intensity),
			randfn(0, shake_intensity)
		)

		if shake_elapsed >= shake_duration:
			# Stop shaking and reset camera offset
			shaking = false
			camera.offset = Vector2.ZERO

			# Show the single dialogue (with image)
			show_dialogue_with_image()


func show_dialogue_with_image():
	# Check if dialogue_2 is still valid before using it
	if is_instance_valid(dialogue_2):
		# Show the dialogue node and start the single dialogue sequence with image
		dialogue_2.visible = true
		dialogue_2.start_dialogue_sequence("falling_from_tower")
	else:
		push_error("Dialogue node is not valid when trying to show dialogue.")


# This function is called when the dialogue_finished signal is emitted
# Keeping the sequence_key argument as the working version had it
func _on_dialogue_finished(sequence_key):
	# print("Dialogue finished!") # Original print for confirmation
	# Use change_scene_to_file for scene transition
	get_tree().change_scene_to_file("res://scenes/Levels/Chapter 2/chapter_2_world_part_3.tscn")
