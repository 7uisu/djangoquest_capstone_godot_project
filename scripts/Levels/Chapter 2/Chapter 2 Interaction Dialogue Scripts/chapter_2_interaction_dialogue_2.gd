extends Control

signal dialogue_finished(sequence_key)

@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var speaker_label: Label = $SpeakerLabel
@onready var continue_warning_label: Label = $ContinueWarningLabel
@onready var texture_rect: TextureRect = $TextureRect

var dialogue_data = {
	"falling_from_tower": {
		"background": "res://textures/Plain Color BG/Sky-Blue.png",
		"dialogue": [
			{"speaker": "Pip", "text": "Whoa—what was that?! The whole tower shook!"},
			{"speaker": "You", "text": "An earthquake? The floor’s—"},
			{"speaker": "Narrator", "text": "CRACK! The platform collapses beneath you."},
			{"speaker": "Pip", "text": "You’re falling! Hang on!"},
			{"speaker": "Narrator", "text": "You crash down to a lower level. Dust settles. Silence."}
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

func _ready() -> void:
	set_process_input(true)
	rich_text_label.text = ""
	speaker_label.text = ""
	continue_warning_label.visible = false
	texture_rect.visible = false
	self.visible = false


func _input(event: InputEvent) -> void:
	# Only process input if the dialogue UI is visible
	if not visible:
		return

	# Only process "ui_accept" action (e.g., Enter, Space, UI Confirm)
	if event.is_action_pressed("ui_accept"):
		if is_typing:
			# If currently typing, skip to the end of the current line
			is_typing = false
			rich_text_label.text = full_current_text
			can_proceed = true
			continue_warning_label.visible = true
		elif can_proceed:
			# If typing is done and we can proceed, move to the next line
			current_line_index += 1

			# Check if there are more lines
			if current_line_index < current_dialogue_lines.size():
				display_current_line()
			else:
				# No more lines, finish the dialogue
				visible = false # Hide the dialogue UI
				emit_signal("dialogue_finished", current_sequence_key) # Emit the signal


func start_dialogue_sequence(sequence_key: String) -> void:
	if not dialogue_data.has(sequence_key):
		push_error("Dialogue sequence key not found: " + sequence_key)
		visible = false
		# Depending on desired behavior, you might still want to emit here
		# emit_signal("dialogue_finished", sequence_key)
		return

	current_sequence_key = sequence_key
	current_dialogue_lines = dialogue_data[sequence_key].get("dialogue", [])
	current_line_index = 0

	# Reset UI elements
	rich_text_label.text = ""
	speaker_label.text = ""
	continue_warning_label.visible = false
	can_proceed = false # Cannot proceed until typing starts/finishes

	# Handle background image
	if dialogue_data[sequence_key].has("background") and is_instance_valid(texture_rect):
		var bg_path = dialogue_data[sequence_key]["background"]
		var bg_tex = load(bg_path) # Assuming path is valid and resource exists
		if bg_tex:
			texture_rect.texture = bg_tex
			texture_rect.visible = true
		else:
			texture_rect.visible = false
			push_error("Failed to load background texture: " + bg_path) # Print error if load fails
	else:
		texture_rect.visible = false


	if current_dialogue_lines.size() > 0:
		visible = true # Make the dialogue UI visible
		display_current_line() # Start displaying the first line
	else:
		push_error("Dialogue sequence '" + sequence_key + "' has no lines.")
		visible = false
		# Depending on desired behavior, you might still want to emit here
		# emit_signal("dialogue_finished", sequence_key)


func display_current_line() -> void:
	if current_line_index >= current_dialogue_lines.size():
		push_error("Attempted to display line index out of bounds: ", current_line_index)
		return

	var line_data = current_dialogue_lines[current_line_index]
	speaker_label.text = line_data.get("speaker", "Narrator")
	full_current_text = line_data.get("text", "")

	rich_text_label.text = "" # Clear previous text
	continue_warning_label.visible = false
	can_proceed = false # Reset state for the new line
	is_typing = true # Start typing

	type_text_async(full_current_text)


func type_text_async(text_to_type: String) -> void:
	# Keep typing flag true while in this coroutine
	is_typing = true

	# Type character by character
	for char_idx in range(text_to_type.length()):
		# Check if typing was interrupted (e.g., by input)
		if not is_typing:
			break # Stop typing loop

		# Add the next character
		rich_text_label.text += text_to_type[char_idx]

		# Wait for typing speed duration
		await get_tree().create_timer(typing_speed).timeout

		# No need for is_instance_valid check here unless the node
		# might be freed *during* the await for other reasons.

	# Typing is finished
	is_typing = false
	rich_text_label.text = full_current_text # Ensure full text is displayed if loop finished naturally
	can_proceed = true
	continue_warning_label.visible = true
