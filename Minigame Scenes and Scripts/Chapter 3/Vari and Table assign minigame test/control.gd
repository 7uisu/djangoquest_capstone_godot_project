extends Control

@onready var question_label = $Label
@onready var question_buttons = [
	$TextureButton,
	$TextureButton2,
	$TextureButton3
]
@onready var answer_panel = $Panel
@onready var answer_buttons = [
	$Panel/TextureButton,
	$Panel/TextureButton2,
	$Panel/TextureButton3,
	$Panel/TextureButton4,
	$Panel/TextureButton5,
	$Panel/TextureButton6
]

var question_images = [
	"res://scenes/Levels/Chapter 3 (5-24-25)/chapter 3 new assets/Texture/minerlogo.jpg",
	"res://scenes/Levels/Chapter 3 (5-24-25)/chapter 3 new assets/Texture/waterfiltlogo.jpg",
	"res://scenes/Levels/Chapter 3 (5-24-25)/chapter 3 new assets/Texture/farminglogo.jpg"
]

var answer_images = [
	"res://scenes/Levels/Chapter 3 (5-24-25)/Vari and Table assign minigame test/legit images/planting/Tools/Watering Can.png",# 0
	"res://scenes/Levels/Chapter 3 (5-24-25)/Vari and Table assign minigame test/legit images/water filtration/pipes.png",# 1
	"res://scenes/Levels/Chapter 3 (5-24-25)/Vari and Table assign minigame test/legit images/water filtration/theMachine.png",# 2
	"res://scenes/Levels/Chapter 3 (5-24-25)/Vari and Table assign minigame test/legit images/mining/Icon31_01.png",# 3
	"res://scenes/Levels/Chapter 3 (5-24-25)/Vari and Table assign minigame test/legit images/mining/Icon31_04.png",# 4
	"res://scenes/Levels/Chapter 3 (5-24-25)/Vari and Table assign minigame test/legit images/planting/Tools/Hoe.png"# 5
]

var question_texts = [
	"What does the Mine need?",
	"What does the Water\nFiltration Room needs?",
	"What does the Garden need?"
]

var correct_answer_indices = [
	[3, 4], # Q1: TextureButton4, TextureButton5
	[1, 2], # Q2: TextureButton2, TextureButton3
	[0, 5]  # Q3: TextureButton, TextureButton6
]

var answered = [false, false, false]
var current_question = -1
var selected_answers = []
var countdown_timer: Timer
var countdown_value = 3

func _ready():
	# Setup countdown timer
	countdown_timer = Timer.new()
	countdown_timer.wait_time = 1.0
	countdown_timer.timeout.connect(on_countdown_tick)
	add_child(countdown_timer)
	
	for i in range(3):
		question_buttons[i].texture_normal = load(question_images[i])
		question_buttons[i].pressed.connect(_on_question_pressed.bind(i))
		question_buttons[i].modulate = Color(1, 1, 1)
	for i in range(6):
		answer_buttons[i].texture_normal = load(answer_images[i])
		answer_buttons[i].pressed.connect(_on_answer_pressed.bind(i))
		answer_buttons[i].visible = false
		answer_buttons[i].modulate = Color(1, 1, 1)
	question_label.text = "Click a picture to answer!"

func _on_question_pressed(idx):
	if answered[idx]:
		return
	current_question = idx
	selected_answers.clear()
	question_label.text = question_texts[idx] + "\n (Select 2 answers)"
	# Reset label color to default
	question_label.add_theme_color_override("font_color", Color(0, 0, 0))
	for btn in answer_buttons:
		btn.visible = true
		btn.modulate = Color(1, 1, 1)
	# Only reset unanswered buttons, leave answered questions gray
	for i in range(question_buttons.size()):
		if answered[i] or i == idx:
			question_buttons[i].modulate = Color(0.7, 0.7, 0.7)
		else:
			question_buttons[i].modulate = Color(1, 1, 1)

func _on_answer_pressed(idx):
	if current_question == -1:
		return
	if idx in selected_answers:
		return
	selected_answers.append(idx)
	answer_buttons[idx].modulate = Color(0.7, 0.7, 1)
	if selected_answers.size() == 2:
		var correct_set = correct_answer_indices[current_question].duplicate()
		var selected_set = selected_answers.duplicate()
		correct_set.sort()
		selected_set.sort()
		if selected_set == correct_set:
			answered[current_question] = true
			question_buttons[current_question].disabled = true
			question_label.text = "Correct!"
			question_label.add_theme_color_override("font_color", Color(0, 1, 0))  # Green text for correct
			for i in correct_set:
				answer_buttons[i].modulate = Color(0, 1, 0)
			# Keep the question button gray
			question_buttons[current_question].modulate = Color(0.7, 0.7, 0.7)
		else:
			question_label.text = "Try again!"
			question_label.add_theme_color_override("font_color", Color(1, 0, 0))  # Red text for incorrect
			# Reset question button color back to normal
			question_buttons[current_question].modulate = Color(1, 1, 1)
			for i in selected_set:
				if i not in correct_set:
					answer_buttons[i].modulate = Color(1, 0, 0)
		
		await get_tree().create_timer(1.0).timeout
		
		# Check if all questions are answered correctly
		var all_answered = true
		for is_answered in answered:
			if not is_answered:
				all_answered = false
				break
		
		if all_answered:
			question_label.text = "Minigame Complete!"
			question_label.add_theme_color_override("font_color", Color(0, 1, 0))  # Green text
			# Start countdown instead of immediate scene change
			start_countdown()
			return
		
		for btn in answer_buttons:
			btn.visible = false
			btn.modulate = Color(1, 1, 1)
		# Only reset color if not answered correctly (if correct, stays gray)
		if not answered[current_question]:
			question_buttons[current_question].modulate = Color(1, 1, 1)
		current_question = -1
		selected_answers.clear()
		# Reset label color and text
		question_label.add_theme_color_override("font_color", Color(1, 1, 1))
		question_label.text = "Click a picture to answer!"

func start_countdown():
	countdown_value = 3
	update_countdown_display()
	countdown_timer.start()

func on_countdown_tick():
	countdown_value -= 1
	if countdown_value > 0:
		update_countdown_display()
	else:
		countdown_timer.stop()
		# Load the next scene (you can change this path to where you want to go next)
		get_tree().change_scene_to_file("res://Minigame Scenes and Scripts/Chapter 3/wiretest/control.tscn")

func update_countdown_display():
	question_label.text = "Minigame Complete!\nNext Task in " + str(countdown_value) + "..."
	question_label.add_theme_color_override("font_color", Color(0, 1, 0))  # Keep green text
