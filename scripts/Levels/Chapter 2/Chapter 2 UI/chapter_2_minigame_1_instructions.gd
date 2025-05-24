# chapter_2_minigame_1_instructions.gd
extends Control

@onready var instruction_label = $Label

var default_instruction = "Help url bot find the right views room"
var success_color = Color.GREEN
var error_color = Color.RED
var default_color = Color.WHITE

func _ready():
	show_default_instructions()

func show_default_instructions():
	instruction_label.text = default_instruction
	instruction_label.modulate = default_color

func show_success_message(message: String):
	instruction_label.text = message
	instruction_label.modulate = success_color

func show_error_message(message: String):
	instruction_label.text = message
	instruction_label.modulate = error_color

func update_instruction(new_text: String, color: Color = Color.WHITE):
	instruction_label.text = new_text
	instruction_label.modulate = color

func reset_instructions():
	show_default_instructions()
