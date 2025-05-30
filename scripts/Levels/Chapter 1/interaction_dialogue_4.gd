extends Control

# Signal to notify when dialogue is finished
signal dialogue_finished

# References to UI elements
@onready var rich_text_label = $RichTextLabel
@onready var speaker_label = $SpeakerLabel
@onready var continue_warning_label = $ContinueWarningLabel
@onready var texture_rect = $TextureRect
@onready var color_rect = $ColorRect

# Dialogue data
var dialogue_data = {
	"snake_escape": {
		"background": "res://textures/Visual Novel Images/Chapter 1/outrun_python.png",
		"dialogue": [
			{"speaker": "Narrator", "text": "You managed to outrun the Python, collecting the scattered pages along the way."},
			{"speaker": "Pip", "text": "Phew! That was close! Good job collecting all those pages!"},
			{"speaker": "You", "text": "*catching breath* Is... is it gone?"},
			{"speaker": "Pip", "text": "For now. Python can really persistent when they're angry"}
		]
	},
	"space_station": {
		"background": "res://textures/Visual Novel Images/Chapter 1/space_station.png",
		"dialogue": [
			{"speaker": "Narrator", "text": "As you catch your breath, you notice a massive structure in the distance."},
			{"speaker": "You", "text": "What is that?"},
			{"speaker": "Pip", "text": "That's the Space Station! Our next destination."}
		]
	},
	"django_explanation": {
		"dialogue": [
			{"speaker": "Pip", "text": "The DjangoBook is connected to that Space Station. It's where we need to go next."},
			{"speaker": "You", "text": "It looks quite abandoned..."},
			{"speaker": "Pip", "text": "We still got more time before going straight to the rocket."},
			{"speaker": "Pip", "text": "We might find something good!"},
			{"speaker": "Narrator", "text": "With the Python temporarily out of sight, you and Pip start making your way toward the Django Space Station..."}
		]
	}
}

# Dialogue state
var current_dialogue = []
var dialogue_index = 0
var typing_speed = 0.03
var is_typing = false
var displaying_text = false
var full_text = ""
var current_sequence = 0
var dialogue_sequences = ["snake_escape", "space_station", "django_explanation"]

func _ready():
	# Initialize UI elements
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process_input(true)
	rich_text_label.text = ""
	speaker_label.text = ""
	continue_warning_label.visible = false
	grab_focus()
	
	# Start with the first dialogue sequence
	start_dialogue(dialogue_sequences[current_sequence])

func _process(delta):
	# This function is now only used for typing animation
	if is_typing:
		# Skip this function as we'll handle typing with timers
		pass

func _input(event):
	if event.is_action_pressed("ui_accept") and visible:
		if is_typing:
			# Skip typing animation and show full text immediately
			is_typing = false
			rich_text_label.text = full_text
			continue_warning_label.visible = true
			displaying_text = true
		elif displaying_text:
			# Move to next dialogue line
			dialogue_index += 1
			
			# Check if we're at the end of the dialogue
			if dialogue_index >= current_dialogue.size():
				# We've reached the end of the current dialogue sequence
				current_sequence += 1
				
				if current_sequence < dialogue_sequences.size():
					# Move to the next dialogue sequence
					dialogue_index = 0
					start_dialogue(dialogue_sequences[current_sequence])
				else:
					# We've reached the end of all dialogue sequences
					print("[DIALOGUE 4] All dialogue sequences complete, emitting signal")
					emit_signal("dialogue_finished")
					
					# Hide this dialogue
					visible = false
			else:
				# Show next line
				display_dialogue_entry()

# Start a dialogue sequence
func start_dialogue(dialogue_key):
	# Reset for this dialogue sequence
	dialogue_index = 0
	is_typing = false
	displaying_text = false
	rich_text_label.text = ""
	speaker_label.text = ""
	
	if dialogue_data.has(dialogue_key):
		var dialogue_set = dialogue_data[dialogue_key]
		
		# Set background image if provided
		if dialogue_set.has("background") and texture_rect:
			var background_texture = load(dialogue_set["background"])
			if background_texture:
				texture_rect.texture = background_texture
				print("[DIALOGUE 4] Background loaded: ", dialogue_set["background"])
			else:
				print("[DIALOGUE 4] Failed to load background: ", dialogue_set["background"])
		elif dialogue_key == "django_explanation":
			# For in-game cutscene without image
			if texture_rect:
				texture_rect.visible = false
		
		# Set up the dialogue entries
		current_dialogue = dialogue_set["dialogue"]
		
		visible = true
		display_dialogue_entry()
	else:
		push_error("Dialogue key not found: " + dialogue_key)
		emit_signal("dialogue_finished")

# Display the current dialogue entry
func display_dialogue_entry():
	if dialogue_index < current_dialogue.size():
		# Get the current dialogue entry
		var entry = current_dialogue[dialogue_index]
		
		# Update speaker label
		speaker_label.text = entry["speaker"]
		
		# Start typing animation
		full_text = entry["text"]
		rich_text_label.text = ""
		continue_warning_label.visible = false
		
		type_text(full_text)
	else:
		# End of dialogue
		end_dialogue()

# Type text character by character with a timer
func type_text(text_to_type):
	is_typing = true
	displaying_text = false
	rich_text_label.text = ""
	
	# Use a simple loop with a timeout
	for i in range(text_to_type.length()):
		if not is_typing:
			# If typing was interrupted, show the full text
			rich_text_label.text = text_to_type
			break
		
		rich_text_label.text += text_to_type[i]
		
		# Create a timer for each character
		var timer = get_tree().create_timer(typing_speed)
		await timer.timeout
	
	# When typing is done (either completed or interrupted)
	is_typing = false
	displaying_text = true
	continue_warning_label.visible = true

# End the dialogue
func end_dialogue():
	print("[DIALOGUE 4] Current dialogue sequence finished")
	# Don't emit signal here, it's handled in _input when all sequences are done
