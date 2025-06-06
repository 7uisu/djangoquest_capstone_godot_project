extends Control
@onready var resume_panel = $ResumePanel
@onready var resume_label = $ResumePanel/ResumeLabel
@onready var resume_image = $ResumePanel/ResumeImage
@onready var mine_button = $MineButton
@onready var water_button = $WaterButton
@onready var farm_button = $FarmButton
@onready var guide_label = $GuidePanel/GuideLabel

var resumes = [
	{
		"text": "Jack Diggerstone -\nBorn into a lineage of legendary miners, Jack once found a gemstone shaped like a heart on his 7th birthday. Since then, he's been digging for treasures—both literal and metaphorical.",
		"image": preload("res://scenes/Levels/Chapter 3 (5-24-25)/Resume minigame/images/5.png"),
		"answer": "mine"
	},
	{
		"text": "Gabriela Watershed -\nTrained by her grandparents in the hills, Gabriela built her first homemade water purifier using bamboo and charcoal at the age of 10. Now, she purifies not just water—but knowledge.",
		"image": preload("res://scenes/Levels/Chapter 3 (5-24-25)/Resume minigame/images/6.png"),
		"answer": "water"
	},
	{
		"text": "Sage Greenfield -\nRaised on a thriving farm, Sage could tell the difference between basil and oregano blindfolded. With a heart as fertile as her land, she's a natural when it comes to nurturing crops.",
		"image": preload("res://scenes/Levels/Chapter 3 (5-24-25)/Resume minigame/images/7.png"),
		"answer": "farm"
	}
]

var current_index = 0
var awaiting_answer = true

func _ready():
	setup_resume()
	guide_label.text = "Based on their Resume, which job would you put them?"
	mine_button.pressed.connect(on_job_button_pressed.bind("mine"))
	water_button.pressed.connect(on_job_button_pressed.bind("water"))
	farm_button.pressed.connect(on_job_button_pressed.bind("farm"))

func setup_resume():
	var resume = resumes[current_index]
	resume_label.text = resume["text"]
	resume_image.texture = resume["image"]
	awaiting_answer = true
	guide_label.text = "Based on their Resume, which job would you put them?"

func on_job_button_pressed(selected_job):
	if not awaiting_answer:
		return
	
	var correct_job = resumes[current_index]["answer"]
	if selected_job == correct_job:
		guide_label.text = "Correct!"
		awaiting_answer = false
		await get_tree().create_timer(1.0).timeout
		current_index += 1
		if current_index < resumes.size():
			setup_resume()
		else:
			# All resumes completed - show completion message and transition
			guide_label.text = "All resumes completed! Well done."
			mine_button.disabled = true
			water_button.disabled = true
			farm_button.disabled = true
			
			# Wait a moment for the player to read the completion message
			await get_tree().create_timer(2.0).timeout
			
			# Transition to the next scene
			transition_to_next_scene()
	else:
		guide_label.text = "Wrong, try again."

func transition_to_next_scene():
	# Update this path to your target scene
	var next_scene_path = "res://scenes/Levels/Chapter 3 (5-24-25)/Story Flow World 3/chapter_3_world_part_3.tscn"
	
	print("Transitioning to: ", next_scene_path)
	var error_code = get_tree().change_scene_to_file(next_scene_path)
	
	if error_code != OK:
		printerr("Error changing scene to: ", next_scene_path, " - Error code: ", error_code)
