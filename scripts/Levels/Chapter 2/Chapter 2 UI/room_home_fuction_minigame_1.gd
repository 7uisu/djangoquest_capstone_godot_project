# room_home_function_minigame_1.gd
extends Control
@onready var question_label = $VBoxContainer/QuestionLabel
@onready var choice1_button = $VBoxContainer/Choice1Button
@onready var choice2_button = $VBoxContainer/Choice2Button
@onready var choice3_button = $VBoxContainer/Choice3Button
@onready var feedback_label = $FeedbackLabel

# Single quiz question
var quiz_question = {
	"question": "Based on this room, what do\nyou think its main function is?",
	"choices": [
		"Farming plants and crops",
		"Storage for Crates and Barrels",
		"Storage for treasures of\nthe dungeon"
	],
	"correct_answer": 0 # Index of correct answer (0-based)
}

var is_quiz_active = false

func _ready():
	visible = false
	setup_button_connections()

func setup_button_connections():
	choice1_button.pressed.connect(_on_choice_selected.bind(0))
	choice2_button.pressed.connect(_on_choice_selected.bind(1))
	choice3_button.pressed.connect(_on_choice_selected.bind(2))

func start_quiz():
	is_quiz_active = true
	show_question()

func show_question():
	question_label.text = quiz_question.question
	
	choice1_button.text = quiz_question.choices[0]
	choice2_button.text = quiz_question.choices[1]
	choice3_button.text = quiz_question.choices[2]
	
	# Reset feedback
	feedback_label.text = ""
	feedback_label.modulate = Color.WHITE
	
	# Enable buttons
	enable_choice_buttons(true)

func _on_choice_selected(choice_index: int):
	if not is_quiz_active:
		return
	
	# Disable buttons to prevent multiple clicks
	enable_choice_buttons(false)
	
	if choice_index == quiz_question.correct_answer:
		feedback_label.text = "Correct! Well done!"
		feedback_label.modulate = Color.GREEN
		
		# Complete quiz after correct answer
		await get_tree().create_timer(2.0).timeout
		complete_quiz()
	else:
		feedback_label.text = "Try again! Think about it.."
		feedback_label.modulate = Color.RED
		
		# Re-enable buttons after a delay
		await get_tree().create_timer(1.5).timeout
		enable_choice_buttons(true)

func enable_choice_buttons(enabled: bool):
	choice1_button.disabled = !enabled
	choice2_button.disabled = !enabled
	choice3_button.disabled = !enabled

func complete_quiz():
	is_quiz_active = false

	question_label.text = "Next Delivery Bot!"
	feedback_label.text = "Fact: You can add any\nfuction to Views."
	feedback_label.modulate = Color.GREEN

	# Show only one button
	choice1_button.visible = false
	choice2_button.visible = true
	choice3_button.visible = false
	
	choice2_button.text = "Continue"
	choice2_button.disabled = false
	
# Reassign the pressed signal to go to the next minigame
	if not choice2_button.pressed.is_connected(go_to_next_minigame):
		choice2_button.pressed.connect(go_to_next_minigame)



func go_to_next_minigame():
	print("DEBUG: Transitioning to next minigame scene...")
	get_tree().change_scene_to_file("res://scenes/Levels/Chapter 2/chapter_2_world_part_4_1st_minigame_pt2.tscn")

func reset_quiz():
	is_quiz_active = false
	visible = false
