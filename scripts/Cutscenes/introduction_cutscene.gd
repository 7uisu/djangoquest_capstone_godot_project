extends Control

var scenes_data = [
	{
		"background": "res://textures/Visual Novel Images/Chapter 1/train_scene.png",
		"dialogue": [
			{"speaker": "Narrator", "text": "The train rumbles onward, carrying the Male and Female Worker towards their future."},
			{"speaker": "Narrator", "text": "Today starts their first day as Junior Developers."},
			{"speaker": "Female Worker", "text": "Here we go again, another day, another train ride. I wonder what's in store for me at this new job.", "character_image_left": "res://textures/Plain Color BG/Sky-Blue.png"},
			{"speaker": "Male Worker", "text": "I can't believe this is happening. My first job as a Junior Developer! I hope I don't screw this up.", "character_image_left": "res://textures/Plain Color BG/Black.png"}
		],
		"image": "res://textures/VisualNovel/scenes/train.png"
	},
	{
		"background": "res://textures/Visual Novel Images/Chapter 1/walking_to_work_scene.png",
		"dialogue": [
			{"speaker": "Narrator", "text": "The city wakes up around them, a symphony of car horns and hurried footsteps.", "character_image": ""},
			{"speaker": "Narrator", "text": "Female Worker adjusts her bag, a mix of nerves and excitement bubbling inside, as is the Male Worker.", "character_image": ""},
			{"speaker": "Female Worker", "text": "Okay, H. I. K. A. Web Solutions, here I come. Time to show them what I've got.", "character_image_left": "res://textures/Plain Color BG/Sky-Blue.png"},
			{"speaker": "Male Worker", "text": "Gotta stay focused, gotta stay sharp. This is my chance to prove myself.", "character_image_left": "res://textures/Plain Color BG/Black.png"}
		],
		"image": "res://textures/VisualNovel/scenes/city.png"
	},
	{
		"background": "res://textures/Visual Novel Images/Chapter 1/company_arrival.png",
		"dialogue": [
			{"speaker": "Narrator", "text": "A towering glass and steel structure, a monument to modern industry. This is it. H. I. K. A. Web Solutions.", "character_image": ""}
		],
		"image": "res://textures/VisualNovel/scenes/company_arrival.png"
	},
	{
		"background": "res://textures/Visual Novel Images/Chapter 1/elevator.png",
		"dialogue": [
			{"speaker": "Narrator", "text": "Inside the elevator, Mateo and Solmi meet.", "character_image": ""},
			{"speaker": "Male Worker", "text": "Morning! First day for you too, huh?", "character_image_left": "res://textures/Plain Color BG/Black.png"},
			{"speaker": "Female Worker", "text": "Yeah, pretty obvious, right? *nervous chuckle*", "character_image_right": "res://textures/Plain Color BG/Sky-Blue.png"},
			{"speaker": "Male Worker", "text": "Don't sweat it. Everyone's a bit lost at first. I'm Mateo, by the way.", "character_image_left": "res://textures/Plain Color BG/Black.png"},
			{"speaker": "Female Worker", "text": "Solmi. Nice to meet you. Any advice?", "character_image_right": "res://textures/Plain Color BG/Sky-Blue.png"},
			{"speaker": "Mateo", "text": "Seriously though, they're good people. Just...passionate about their code. Welcome to the Thunderdome!", "character_image_left": "res://textures/Plain Color BG/Black.png"},
		],
		"image": "res://textures/VisualNovel/scenes/elevator.png"
	},
	{
		"background": "res://textures/Visual Novel Images/Chapter 1/elevator_open.png",
		"dialogue": [
			{"speaker": "Narrator", "text": "Elevator doors open.", "character_image": ""},
			{"speaker": "Mateo", "text": "Looks like this is our floor.", "character_image_left": "res://textures/Plain Color BG/Black.png"}
		],
		"image": "res://textures/VisualNovel/scenes/elevator.png"
	},
	{
		"background": "res://textures/Visual Novel Images/Chapter 1/senior_dev_intro.png",
		"dialogue": [
			{"speaker": "Narrator", "text": "Mateo and Solmi are greeted by the SENIOR DEVELOPER.", "character_image": ""},
			{"speaker": "Kevin", "text": "Welcome to H. I. K. A. Web Solutions, Solmi and Mateo. I'm Kevin.", "character_image_left": "res://textures/Plain Color BG/Black.png"},
			{"speaker": "Kevin", "text": "I'll be showing you both the ropes. Come on, let's get you to your desks.", "character_image_left": "resres://textures/Plain Color BG/Black.png"}
		],
		"image": "res://textures/VisualNovel/scenes/senior_dev_intro.png"
	},
	{
		"background": "res://textures/VisualNovel/backgrounds/pc_setup.png",
		"dialogue": [
			{"speaker": "Narrator", "text": "Mateo and Solmi notice their PC isn't properly set up.", "character_image": ""},
			{"speaker": "Narrator", "text": "They begin setting up VS Code and other tools.", "character_image": ""},
			{"speaker": "Narrator", "text": "Time to dive in. The setup is a bit of a mess, but nothing Solmi and Mateo can't handle.", "character_image": ""},
			{"speaker": "BOSS", "text": "Solmi and Mateo! In my office, please!", "character_image": "g"},
		],
		"image": "res://textures/VisualNovel/scenes/pc_setup.png"
	},
	# Add more scenes here
]

var current_scene_index = 0
var current_dialogue_index = 0
var typing = false
var skip_next_typing = false
var displaying_text = false

@onready var background = $TextureRect
@onready var text_label = $RichTextLabel
@onready var speaker_label = $SpeakerLabel
@onready var continue_label = $ContinueWarningLabel
@onready var character_image_left = $CharacterImageLeft  # Left character image
@onready var character_image_right = $CharacterImageRight  # Right character image
@onready var skip_button = $SkipButton  # Skip button

func _ready():
	setup_skip_button()
	show_scene()

func setup_skip_button():
	# Connect the skip button signal
	skip_button.pressed.connect(_on_skip_button_pressed)
	skip_button.text = "Skip"

func show_scene():
	if current_scene_index < scenes_data.size():
		background.texture = load(scenes_data[current_scene_index]["background"])
		current_dialogue_index = 0
		show_text()
	else:
		start_game()

func show_text():
	if current_scene_index < scenes_data.size() and current_dialogue_index < scenes_data[current_scene_index]["dialogue"].size():
		var current_dialogue = scenes_data[current_scene_index]["dialogue"][current_dialogue_index]
		var speaker = current_dialogue.speaker
		var text = current_dialogue.text
		var character_image_left_path = current_dialogue.get("character_image_left", "")
		var character_image_right_path = current_dialogue.get("character_image_right", "")
		
		# Set speaker label
		if speaker == "Narrator":
			speaker_label.text = ""
		else:
			speaker_label.text = speaker
		
		# Handle character images
		update_character_images(character_image_left_path, character_image_right_path)
		
		text_label.text = ""
		if typing:
			return
		if skip_next_typing:
			text_label.text = text
			typing = false
			skip_next_typing = false
			continue_label.show()
		else:
			type_text(text)
	else:
		current_scene_index += 1
		show_scene()

func update_character_images(left_image_path: String, right_image_path: String):
	# Handle left character image
	if left_image_path != "":
		character_image_left.texture = load(left_image_path)
		character_image_left.visible = true
	else:
		character_image_left.visible = false
	
	# Handle right character image
	if right_image_path != "":
		character_image_right.texture = load(right_image_path)
		character_image_right.visible = true
	else:
		character_image_right.visible = false

func _input(event):
	if event.is_action_pressed("ui_accept"):
		if typing:
			typing = false
			text_label.text = scenes_data[current_scene_index]["dialogue"][current_dialogue_index]["text"]
			continue_label.show()
		elif displaying_text:
			current_dialogue_index += 1
			show_text()

func _on_skip_button_pressed():
	# Skip directly to character select scene
	start_game()

func start_game():
	get_tree().change_scene_to_file("res://scenes/UI/character_select.tscn")

func type_text(full_text):
	typing = true
	displaying_text = true
	text_label.text = ""
	continue_label.hide()
	
	for i in range(full_text.length()):
		text_label.text += full_text[i]
		await get_tree().create_timer(0.05).timeout
		if not typing:
			break
	
	typing = false
	displaying_text = true
	continue_label.show()
	skip_next_typing = false
