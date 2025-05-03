extends Control
signal dialogue_finished
@onready var text_box = $ColorRect
@onready var text_label = $RichTextLabel
@onready var speaker_label = $SpeakerLabel
@onready var continue_label = $ContinueWarningLabel
var dialogue_data = {
	"pip_django_explanation": [
		{"speaker": "Pip", "text": "Meow! I see you found a Django book."},
		{"speaker": "Pip", "text": "Django is a powerful web framework written by Python."},
		{"speaker": "Narrator", "text": "Django helps developers build web applications quickly and cleanly."},
		{"speaker": "Narrator", "text": "It follows a pattern called 'Model-View-Template', or MVT for short."},
		{"speaker": "Pip", "text": "It's designed to make building a rocket and its framework faster and easier."},
		{"speaker": "Narrator", "text": "With Django, you define your data using something called models."},
		{"speaker": "Narrator", "text": "Then, you use views to decide what data to show and how to handle user actions."},
		{"speaker": "Narrator", "text": "Finally, templates help you design how things look in the browser."},
		{"speaker": "Pip", "text": "The book you just saw covers Django basics like models, views, templates, and forms."},
		{"speaker": "Narrator", "text": "Forms let users enter and send data to your site."},
		{"speaker": "Narrator", "text": "They work closely with models to save that data in a database."},
		{"speaker": "Pip", "text": "Learning Django will help you build and make the rocket work!!"},
		{"speaker": "Pip", "text": "But as you can see, the other chapters are missing, we only have the Chapter 1"},
		{"speaker": "Pip", "text": "'Starting the Rocket'"},
		{"speaker": "Narrator", "text": "Chapter 1 will help you start your first Django project."},
		{"speaker": "Narrator", "text": "You'll set up your environment and create your first app."},
		{"speaker": "Pip", "text": "I wonder where could the other pages be.."}
	],
	"default": [
		{"speaker": "Pip", "text": "Meow! I'm Pip, your coding companion!"},
		{"speaker": "Pip", "text": "I'll be here to help you throughout your journey as a developer."}
	]
}
var current_dialogue = []
var current_dialogue_index = 0
var typing = false
var displaying_text = false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process_input(true)
	text_label.text = ""
	speaker_label.text = ""
	continue_label.hide()
	grab_focus()

func start_dialogue(dialogue_id: String = "default"):
	# Reset everything
	current_dialogue_index = 0
	typing = false
	displaying_text = false
	text_label.text = ""
	speaker_label.text = ""
	
	# Get the dialogue data
	if dialogue_data.has(dialogue_id):
		current_dialogue = dialogue_data[dialogue_id]
	else:
		current_dialogue = dialogue_data["default"]
		push_warning("Dialogue ID '" + dialogue_id + "' not found, using default")
	
	visible = true
	show_text()

func _input(event):
	if event.is_action_pressed("ui_accept") and visible:
		if typing:
			# Skip typing animation and show full text immediately
			typing = false
			text_label.text = current_dialogue[current_dialogue_index]["text"]
			continue_label.show()
			displaying_text = true
		elif displaying_text:
			# Move to next dialogue line
			current_dialogue_index += 1
			
			# Check if we're at the end of the dialogue
			if current_dialogue_index >= current_dialogue.size():
				# We've reached the end of the dialogue, finish it
				print("Dialogue complete, emitting signal")
				emit_signal("dialogue_finished")
				
				# Immediately free this node to prevent any further processing
				call_deferred("queue_free")  # This defers the cleanup to the next frame
			else:
				# Show next line
				show_text()

func show_text():
	if current_dialogue_index < current_dialogue.size():
		var line = current_dialogue[current_dialogue_index]
		speaker_label.text = line["speaker"] if line["speaker"] != "Narrator" else ""
		text_label.text = ""
		continue_label.hide()
		type_text(line["text"])

func type_text(full_text):
	typing = true
	displaying_text = false
	text_label.text = ""
	
	# Use a simple loop with a timeout
	for i in range(full_text.length()):
		if not typing:
			# If typing was interrupted, show the full text
			text_label.text = full_text
			break
		
		text_label.text += full_text[i]
		
		# Create a timer for each character
		var timer = get_tree().create_timer(0.03)
		await timer.timeout
	
	# When typing is done (either completed or interrupted)
	typing = false
	displaying_text = true
	continue_label.show()
