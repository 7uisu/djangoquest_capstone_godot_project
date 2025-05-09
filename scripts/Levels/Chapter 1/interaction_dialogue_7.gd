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
	"start_of_space_journey": {
		"dialogue": [
			{"speaker": "Narrator", "text": "The Django Rocket zooms through the starry expanse, leaving Earth far behind."},
			{"speaker": "Pip", "text": "We need to collect all the missing Chapter 1 pages of the DjangoBook. They've been scattered across different web planets!"},
			{"speaker": "Narrator", "text": "Django, created in 2003, is a high-level Python web framework that follows the Model-View-Template architectural pattern."},
			{"speaker": "Pip", "text": "First stop, the HTML Planet! That's where we'll find the Template pages of the DjangoBook."},
			{"speaker": "Narrator", "text": "Django's template system allows developers to define the structure of output documents with placeholders for dynamic data."},
			{"speaker": "Pip", "text": "Then we'll head to Data Planet, where the Model pages are hidden. Those pages explain how Django interacts with databases!"},
			{"speaker": "Narrator", "text": "Django's Object-Relational Mapping (ORM) allows developers to define database models in Python code, making database operations simpler."},
			{"speaker": "Pip", "text": "And finally, we need to visit the URL Planet to recover the View pages. They control what happens when users visit different web addresses."},
			{"speaker": "Narrator", "text": "Django's URL dispatcher maps URL patterns to view functions, which determine what content is returned to the user."},
			{"speaker": "Pip", "text": "Once we have all the pages, we can rebuild Chapter 1 of your DjangoBook and you'll understand how Django's MVT architecture works together!"},
			{"speaker": "Narrator", "text": "Django's name was inspired by the famous jazz guitarist Django Reinhardt, reflecting the framework's goal of creating harmony between different web components."},
			{"speaker": "Pip", "text": "Look! The HTML Planet is coming into view. Are you ready to start our adventure and collect the first set of pages?"},
			{"speaker": "Pip", "text": "Ready when you are! Just press the spacebar and we'll begin our landing approach."}
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

func _ready():
	# Initialize UI elements
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process_input(true)
	rich_text_label.text = ""
	speaker_label.text = ""
	continue_warning_label.visible = false
	grab_focus()

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
				# We've reached the end of the dialogue, finish it
				print("[DIALOGUE 7] Dialogue complete, emitting signal")
				emit_signal("dialogue_finished")
				
				# Immediately free this node to prevent any further processing
				call_deferred("queue_free")
			else:
				# Show next line
				display_dialogue_entry()

# Start a dialogue sequence
func start_dialogue(dialogue_key):
	# Reset everything
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
				print("[DIALOGUE 7] Background loaded: ", dialogue_set["background"])
			else:
				print("[DIALOGUE 7] Failed to load background: ", dialogue_set["background"])
		
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
	print("[DIALOGUE 7] Dialogue finished, emitting signal")
	emit_signal("dialogue_finished")
	queue_free()  # Remove dialogue from the scene
