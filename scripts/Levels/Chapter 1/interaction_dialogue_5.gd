#interaction_dialogue_5.gd
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
	"python_appearance": {
		"dialogue": [
			{"speaker": "Narrator", "text": "As you reach the entrance of the Space Station, a familiar figure slithers into view."},
			{"speaker": "Python", "text": "Well, well, well... fancy meeting you here."},
			{"speaker": "You", "text": "*gasps* How did it find us so quickly?"},
			{"speaker": "Python", "text": "This is MY territory. The Django Space Station is built on Python foundations, after all."},
			{"speaker": "Pip", "text": "We're just here to access the DjangoBook. We don't want any trouble."}
		]
	},
	"aggression": {
		"dialogue": [
			{"speaker": "Python", "text": "The DjangoBook? That's not for amateurs like you who can't even handle basic syntax!"},
			{"speaker": "Pip", "text": "We've been learning and practicing. We deserve a chance."},
			{"speaker": "Python", "text": "Deserve? DESERVE?! You think you DESERVE access to Django's power?"},
			{"speaker": "Python", "text": "You must EARN it by defeating me in a coding challenge!"},
			{"speaker": "Pip", "text": "*whispers* We can do this. Remember what you've learned about Python basics."}
		]
	},
	"battle_setup": {
		"background": "res://textures/Plain Color BG/Sky-Blue.png",
		"dialogue": [
			{"speaker": "Narrator", "text": "The Python rises up, towering over you menacingly."},
			{"speaker": "Python", "text": "Time to see if you've learned anything at all about Python! Let's battle!"},
			{"speaker": "Pip", "text": "Ready yourself! Use your Python knowledge to fight back!"},
			{"speaker": "You", "text": "*gulps* Here we go..."},
			{"speaker": "Narrator", "text": "The second mini-game begins, testing your Python skills against the mighty serpent..."}
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
var dialogue_sequences = ["python_appearance", "aggression", "battle_setup"]

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
					print("[DIALOGUE 5] All dialogue sequences complete, emitting signal")
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
				texture_rect.visible = true
				print("[DIALOGUE 5] Background loaded: ", dialogue_set["background"])
			else:
				print("[DIALOGUE 5] Failed to load background: ", dialogue_set["background"])
		else:
			# For in-game cutscene without image
			if texture_rect:
				texture_rect.visible = false
				print("[DIALOGUE 5] Not using background for this sequence")
		
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
	print("[DIALOGUE 5] Current dialogue sequence finished")
	# Don't emit signal here, it's handled in _input when all sequences are done
