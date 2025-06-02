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
		"text": "Jack Do \n
				Came from a generation of miners",
		"image": preload("res://scenes/Levels/Chapter 3 (5-24-25)/Resume minigame/images/bearded-idle-1.png"),
		"answer": "mine"
	},
	{
		"text": "Gabriela Silang \n
				Taught at a very young age how water filtration works",
		"image": preload("res://scenes/Levels/Chapter 3 (5-24-25)/Resume minigame/images/woman-idle-1.png"),
		"answer": "water"
	},
	{
		"text": "Wise Doe \n
				I am very good at handling crops and plants",
		"image": preload("res://scenes/Levels/Chapter 3 (5-24-25)/Resume minigame/images/hat-man-idle-1.png"),
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
	guide_label.text = "Based on their Resume, which job would you put him?"

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
			guide_label.text = "All resumes completed! Well done."
			mine_button.disabled = true
			water_button.disabled = true
			farm_button.disabled = true
	else:
		guide_label.text = "Wrong, try again."
