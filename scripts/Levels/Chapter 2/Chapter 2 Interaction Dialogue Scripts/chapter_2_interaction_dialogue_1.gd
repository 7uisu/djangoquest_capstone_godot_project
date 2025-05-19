extends Control

signal dialogue_finished

@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var speaker_label: Label = $SpeakerLabel
@onready var continue_warning_label: Label = $ContinueWarningLabel
@onready var texture_rect: TextureRect = $TextureRect

# Adjust the path to your actual player node here
@onready var player = get_node("/root/Playground/Player")

var dialogue_data = {
	"arrival_chapter_2": {
		"dialogue": [
			{"speaker": "Pip", "text": "Whoa, this place looks... intricate! That tower is massive!"},
			{"speaker": "You", "text": "It feels different from Chapter 1. Almost like... a giant puzzle."},
			{"speaker": "Narrator", "text": "The air crackles with latent code. The next part of the Django Book must be close."},
			{"speaker": "Pip", "text": "Let's explore! I bet there are Django Pages scattered around here too."}
		]
	}
}

var current_dialogue_lines: Array = []
var current_line_index: int = 0
var typing_speed: float = 0.03
var is_typing: bool = false
var can_proceed: bool = false
var full_current_text: String = ""

var current_sequence_key: String = ""
var dialogue_sequence_keys: Array = ["arrival_chapter_2"]
var current_sequence_index: int = 0

func _ready() -> void:
	set_process_input(true)

	rich_text_label.text = ""
	speaker_label.text = ""
	continue_warning_label.visible = false
	texture_rect.visible = false
	
	self.visible = true
	grab_focus()

	# Disable player movement at dialogue start
	if player:
		player.can_move = false

	if dialogue_sequence_keys.size() > 0:
		start_dialogue_sequence(dialogue_sequence_keys[current_sequence_index])
	else:
		printerr("No dialogue sequences defined for DjangoBookChapter2!")
		visible = false

func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("ui_accept"):
		if is_typing:
			is_typing = false
			rich_text_label.text = full_current_text
			can_proceed = true
			continue_warning_label.visible = true
		elif can_proceed:
			current_line_index += 1
			if current_line_index < current_dialogue_lines.size():
				display_current_line()
			else:
				current_sequence_index += 1
				if current_sequence_index < dialogue_sequence_keys.size():
					start_dialogue_sequence(dialogue_sequence_keys[current_sequence_index])
				else:
					print("[Chapter2InteractionDialogue1] All dialogue finished.")
					# Re-enable player movement after dialogue ends
					if player:
						player.can_move = true

					emit_signal("dialogue_finished")
					visible = false

func start_dialogue_sequence(sequence_key: String) -> void:
	if not dialogue_data.has(sequence_key):
		printerr("Dialogue sequence key not found in dialogue_data: '", sequence_key, "'")
		visible = false
		emit_signal("dialogue_finished")
		return

	current_sequence_key = sequence_key
	current_dialogue_lines = dialogue_data[sequence_key].get("dialogue", [])
	current_line_index = 0

	rich_text_label.text = ""
	speaker_label.text = ""
	continue_warning_label.visible = false
	texture_rect.visible = false

	if current_dialogue_lines.size() > 0:
		display_current_line()
	else:
		printerr("Dialogue sequence '", sequence_key, "' has no lines.")
		visible = false
		emit_signal("dialogue_finished")

func display_current_line() -> void:
	if current_line_index >= current_dialogue_lines.size():
		return

	var line_data = current_dialogue_lines[current_line_index]
	speaker_label.text = line_data.get("speaker", "Narrator")
	full_current_text = line_data.get("text", "")

	rich_text_label.text = ""
	continue_warning_label.visible = false
	can_proceed = false

	type_text_async(full_current_text)

func type_text_async(text_to_type: String) -> void:
	is_typing = true
	for char_idx in range(text_to_type.length()):
		if not is_typing:
			rich_text_label.text = text_to_type
			break
		rich_text_label.text += text_to_type[char_idx]
		await get_tree().create_timer(typing_speed).timeout
		if not is_instance_valid(self): return

	if is_instance_valid(self):
		is_typing = false
		can_proceed = true
		continue_warning_label.visible = true
