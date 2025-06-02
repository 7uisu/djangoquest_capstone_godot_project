# guide_instructions.gd
extends Control

@onready var instruction_label: Label = $Label  # Assuming you have a Label node
var countdown_timer: float = 3.0
var is_counting_down: bool = false

func _ready():
	# Initially hide or show default instruction
	if instruction_label:
		instruction_label.text = "Find the Computer deep in the Mines."
		instruction_label.visible = true

func _process(delta: float):
	if is_counting_down:
		countdown_timer -= delta
		
		if countdown_timer > 0:
			# Update countdown text
			var seconds_left = ceil(countdown_timer)
			instruction_label.text = "Starting task in " + str(seconds_left) + "-"
		else:
			# Countdown finished, transition to minigame
			transition_to_minigame()

func start_countdown():
	"""Call this function to begin the countdown"""
	if not is_counting_down:
		is_counting_down = true
		countdown_timer = 3.0
		print("Starting countdown...")

func transition_to_minigame():
	"""Transition to the minigame scene"""
	print("Transitioning to minigame...")
	get_tree().change_scene_to_file("res://scenes/Levels/Chapter 3 (5-24-25)/Vari and Table assign minigame test/control.tscn")

# Call this function from your computer interaction or trigger
func trigger_countdown():
	start_countdown()
