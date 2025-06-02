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
	"res://scenes/Levels/Chapter 3 (5-24-25)/Vari and Table assign minigame test/images/Mita.png",
	"res://scenes/Levels/Chapter 3 (5-24-25)/Vari and Table assign minigame test/images/korone.jpg",
	"res://scenes/Levels/Chapter 3 (5-24-25)/Vari and Table assign minigame test/images/Aru.png"
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
	"What does the Water Filtration Room needs?",
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

func _ready():
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
			for i in correct_set:
				answer_buttons[i].modulate = Color(0, 1, 0)
			# Keep the question button gray
			question_buttons[current_question].modulate = Color(0.7, 0.7, 0.7)
		else:
			question_label.text = "Try again!"
			# Reset question button color back to normal
			question_buttons[current_question].modulate = Color(1, 1, 1)
			for i in selected_set:
				if i not in correct_set:
					answer_buttons[i].modulate = Color(1, 0, 0)
		await get_tree().create_timer(1.0).timeout
		for btn in answer_buttons:
			btn.visible = false
			btn.modulate = Color(1, 1, 1)
		# Only reset color if not answered correctly (if correct, stays gray)
		if not answered[current_question]:
			question_buttons[current_question].modulate = Color(1, 1, 1)
		current_question = -1
		selected_answers.clear()
