extends Control

var scenes_data = [
	{
		"background": "res://textures/VisualNovel/backgrounds/train.png",
		"dialogue": [
			{"speaker": "Narrator", "text": "The train rumbles onward, carrying the Male and Female Worker towards their future."},
			{"speaker": "Narrator", "text": "Today starts their first day as Junior Developers."},
			{"speaker": "Female Worker", "text": "Here we go again, another day, another train ride. I wonder what's in store for me at this new job."},
			{"speaker": "Male Worker", "text": "I can't believe this is happening. My first job as a Junior Developer! I hope I don't screw this up."}
		],
		"image": "res://textures/VisualNovel/scenes/train.png" # Added image path
	},
	{
		"background": "res://textures/VisualNovel/backgrounds/city.png",
		"dialogue": [
			{"speaker": "Narrator", "text": "The city wakes up around them, a symphony of car horns and hurried footsteps."},
			{"speaker": "Narrator", "text": "Female Worker adjusts her bag, a mix of nerves and excitement bubbling inside, as is the Male Worker."},
			{"speaker": "Female Worker", "text": "Okay, H. I. K. A. Web Solutions, here I come. Time to show them what I've got."},
			{"speaker": "Male Worker", "text": "Gotta stay focused, gotta stay sharp. This is my chance to prove myself."}
		],
		 "image": "res://textures/VisualNovel/scenes/city.png"
	},
	{
		"background": "res://textures/VisualNovel/backgrounds/company_arrival.png",
		"dialogue": [
			{"speaker": "Narrator", "text": "A towering glass and steel structure, a monument to modern industry. This is it. H. I. K. A. Web Solutions."}
		],
		"image": "res://textures/VisualNovel/scenes/company_arrival.png"
	},
	{
		"background": "res://textures/VisualNovel/backgrounds/elevator.png",
		"dialogue": [
			{"speaker": "Narrator", "text": "Inside the elevator, Mateo and Solmi meet."},
			{"speaker": "Male Worker", "text": "Morning! First day for you too, huh?"},
			{"speaker": "Female Worker", "text": "Yeah, pretty obvious, right? *nervous chuckle*"},
			{"speaker": "Male Worker", "text": "Don't sweat it. Everyone's a bit lost at first. I'm Mateo, by the way."},
			{"speaker": "Female Worker", "text": "Solmi. Nice to meet you. Any advice?"},
			{"speaker": "Mateo", "text": "Seriously though, they're good people. Just...passionate about their code. Welcome to the Thunderdome!"},
			{"speaker": "Narrator", "text": "Elevator doors open."},
			{"speaker": "Mateo", "text": "Looks like this is our floor."}
		],
		"image": "res://textures/VisualNovel/scenes/elevator.png"
	},
	{
		"background": "res://textures/VisualNovel/backgrounds/senior_dev_intro.png",
		"dialogue": [
			{"speaker": "Narrator", "text": "Mateo and Solmi are greeted by the SENIOR DEVELOPER."},
			{"speaker": "Sunshine", "text": "Welcome to H. I. K. A. Web Solutions, Solmi and Mateo. I'm Sunshine."},
			{"speaker": "Sunshine", "text": "I'll be showing you both the ropes. Come on, let's get you to your desks."}
		],
		"image": "res://textures/VisualNovel/scenes/senior_dev_intro.png"
	},
	{
		"background": "res://textures/VisualNovel/backgrounds/pc_setup.png",
		"dialogue": [
			{"speaker": "Narrator", "text": "Mateo and Solmi notice their PC isn’t properly set up."},
			{"speaker": "Narrator", "text": "They begin setting up VS Code and other tools."},
			{"speaker": "Narrator", "text": "Time to dive in. The setup is a bit of a mess, but nothing Solmi and Mateo can't handle."},
			{"speaker": "BOSS", "text": "Solmi and Mateo! In my office, please!"},
		],
		"image": "res://textures/VisualNovel/scenes/pc_setup.png"
	},
	# Add more scenes here
]

var current_scene_index = 0
var current_dialogue_index = 0
var typing = false
var skip_next_typing = false  # Flag to skip the *next* dialogue's typing

@onready var background = $TextureRect
@onready var text_label = $RichTextLabel
@onready var next_button = $Button
@onready var speaker_label = $SpeakerLabel  # Added SpeakerLabel

func _ready():
	show_scene()

func show_scene():
	if current_scene_index < scenes_data.size():
		background.texture = load(scenes_data[current_scene_index]["background"])
		current_dialogue_index = 0
		show_text()
		if scenes_data[current_scene_index].has("image"): # Added image display
			#display image
			pass # Replace pass with code to display image.
	else:
		start_game()

func show_text():
	if current_scene_index < scenes_data.size() and current_dialogue_index < scenes_data[current_scene_index]["dialogue"].size():
		var current_dialogue = scenes_data[current_scene_index]["dialogue"][current_dialogue_index]
		var speaker = current_dialogue.speaker
		var text = current_dialogue.text
		if speaker == "Narrator":
			speaker_label.text = ""
		else:
			speaker_label.text = speaker
		text_label.text = "" # Clear previous text
		if typing:
			return
		if skip_next_typing:
			text_label.text = text
			typing = false
			skip_next_typing = false
		else:
			type_text(text)
	else:
		current_scene_index += 1
		show_scene()

func _on_next_button_pressed():
	if typing:
		typing = false
		text_label.text = scenes_data[current_scene_index]["dialogue"][current_dialogue_index]["text"]
	else:
		current_dialogue_index += 1
		show_text()

func start_game():
	get_tree().change_scene_to_file("res://scenes/UI/character_select.tscn")

func type_text(full_text):
	typing = true
	text_label.text = ""
	for i in range(full_text.length()):
		text_label.text += full_text[i]
		await get_tree().create_timer(0.05).timeout
		if not typing:
			break
	typing = false
