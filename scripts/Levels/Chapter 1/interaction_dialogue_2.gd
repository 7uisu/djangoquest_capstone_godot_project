extends Control
signal dialogue_finished
@onready var text_box = $ColorRect
@onready var text_label = $RichTextLabel
@onready var speaker_label = $SpeakerLabel
@onready var continue_label = $ContinueWarningLabel
var dialogue_data = {
	"snake_introduction": [
		{"speaker": "Pip", "text": "Look! It's Python!"},
		{"speaker": "Python", "text": "Sssss! There you are, you fuzzy thief! Hand over the Django Book!"},
		{"speaker": "Pip", "text": "Python is a wise and powerful serpent, known across the land for being dramatic."},
		{"speaker": "Python", "text": "Sssss! Dramatic? Me? I am simply a creature of sophistication and wisdom! "},
		{"speaker": "Narrator", "text": "Python is a high-level programming language."},
		{"speaker": "Narrator", "text": "It's easy to read, write, and understand, which makes it great for beginners."},
		{"speaker": "Narrator", "text": "You can use Python to build websites, analyze data, and even train AI models."},
		{"speaker": "Python", "text": "Sssss! Give back the book now, Human.. Ssssss!"},
		{"speaker": "Narrator", "text": "Python is also widely used in automation, game development, and more."},
		{"speaker": "Pip", "text": "What if we don't wanna?"},
		{"speaker": "Narrator", "text": "Django is a web framework written in Python."},
		{"speaker": "Narrator", "text": "Together, they allow you to create dynamic, database-powered websites."},
		{"speaker": "Python", "text": "Then I will make you both my feast! "},
		{"speaker": "Python", "text": "*Deep, rumbling hiss with a faint growl*"}
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
				call_deferred("queue_free")
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
