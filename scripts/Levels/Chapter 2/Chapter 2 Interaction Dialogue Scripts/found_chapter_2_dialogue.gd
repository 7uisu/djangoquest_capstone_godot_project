extends Control

signal dialogue_finished

@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var speaker_label: Label = $SpeakerLabel
@onready var continue_warning_label: Label = $ContinueWarningLabel
@onready var texture_rect: TextureRect = $TextureRect
# @onready var color_rect: ColorRect = $ColorRect

# Reference to the player node (adjust this path to your actual player node)
@onready var player = get_node("/root/Playground/Player") 
# Change "/root/MainScene/Player" to the actual path of your player node

# Dialogue data - WITH CORRECTED LINE AND KEY USAGE
var dialogue_data = {
	"found_chapter_2": { # This is the key we will use
		# Example with an image for the sequence
		# "background": "res://path/to/your/discovery_image.png",
		"dialogue": [
			{"speaker": "Pip", "text": "Success! It seems we've found the chapter 2 page already!"},
			{"speaker": "You", "text": "Well, that was a fast find!"} # Corrected/completed line
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

# ***** CORRECTED KEY USAGE HERE *****
# Set this to the specific sequence you want to play when triggered.
var default_sequence_to_play: String = "found_chapter_2" # Use the actual key from dialogue_data
# If you want it to play through a list of sequences (even if it's just one):
var dialogue_sequence_keys: Array = ["found_chapter_2"] # Use the actual key
var current_sequence_index: int = 0


func _ready() -> void:
	# This dialogue starts hidden and is triggered externally
	visible = false
	set_process_input(false) # Don't process input until visible and active
	rich_text_label.text = ""
	speaker_label.text = ""
	continue_warning_label.visible = false
	texture_rect.visible = false


# Public method to be called by the trigger
func start_this_dialogue(sequence_key_override: String = "") -> void:
	visible = true
	set_process_input(true)
	grab_focus()

	# Disable player movement when dialogue starts
	if player:
		player.can_move = false

	current_sequence_index = 0 # Reset sequence progression

	var key_to_start = default_sequence_to_play # This will now be "found_chapter_2"
	
	# This logic allows overriding the default sequence if needed when calling start_this_dialogue
	if sequence_key_override != "" and dialogue_data.has(sequence_key_override):
		key_to_start = sequence_key_override
		if dialogue_sequence_keys.has(key_to_start): # Check if override is in defined sequences
			current_sequence_index = dialogue_sequence_keys.find(key_to_start)
		else: # If override is not in the list, just make it the only sequence to play
			dialogue_sequence_keys = [key_to_start]
			current_sequence_index = 0
	
	# Check if the key_to_start (which is dialogue_sequence_keys[current_sequence_index] if not overridden) is valid
	if current_sequence_index < dialogue_sequence_keys.size() and dialogue_data.has(dialogue_sequence_keys[current_sequence_index]):
		start_dialogue_sequence(dialogue_sequence_keys[current_sequence_index])
	else: # Fallback or error if the default or overridden key is still not found (shouldn't happen with corrected keys)
		if dialogue_data.has(key_to_start): # Try key_to_start directly if array logic failed
			start_dialogue_sequence(key_to_start)
		else:
			printerr("No valid dialogue sequence to start for FoundChapter2Dialogue. Tried key: '", key_to_start, "' and default sequence array.")
			visible = false
			set_process_input(false)


func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("ui_accept"):
		if is_typing:
			is_typing = false
			rich_text_label.text = full_current_text
			# For Godot 4.x using visible_characters:
			# rich_text_label.visible_characters = len(full_current_text)
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
					print("[FoundChapter2Dialogue] All dialogue finished.")
					# Re-enable player movement when dialogue ends
					if player:
						player.can_move = true
					emit_signal("dialogue_finished")
					visible = false
					set_process_input(false) # Disable input processing

func start_dialogue_sequence(sequence_key: String) -> void:
	if not dialogue_data.has(sequence_key):
		printerr("Dialogue sequence key not found in dialogue_data: '", sequence_key, "'")
		visible = false
		set_process_input(false)
		emit_signal("dialogue_finished")
		return

	current_sequence_key = sequence_key
	var sequence_content = dialogue_data[sequence_key]

	current_dialogue_lines = sequence_content.get("dialogue", [])
	current_line_index = 0
	
	is_typing = false
	can_proceed = false
	rich_text_label.text = ""
	speaker_label.text = ""
	
	if sequence_content.has("background") and texture_rect:
		var bg_texture = load(sequence_content["background"])
		if bg_texture:
			texture_rect.texture = bg_texture
			texture_rect.visible = true
		else:
			printerr("Failed to load background: ", sequence_content["background"])
			texture_rect.visible = false
	elif texture_rect:
		texture_rect.visible = false 

	if current_dialogue_lines.size() > 0:
		display_current_line()
	else:
		printerr("Dialogue sequence '", sequence_key, "' has no lines.")
		visible = false
		set_process_input(false)
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

	var image_path = line_data.get("image") # Per-line image
	var sequence_has_bg = dialogue_data[current_sequence_key].has("background")

	if image_path and image_path != "" and texture_rect:
		var line_texture = load(image_path)
		if line_texture:
			texture_rect.texture = line_texture
			texture_rect.visible = true
		else:
			printerr("Failed to load line image: ", image_path)
			# If line image fails to load, show sequence background if it exists, else hide
			texture_rect.visible = sequence_has_bg 
			if sequence_has_bg:
				texture_rect.texture = load(dialogue_data[current_sequence_key]["background"]) # Reload sequence BG
			else:
				texture_rect.texture = null # Clear texture
	elif not sequence_has_bg : 
		# No line image AND no sequence background, so hide texture_rect
		if texture_rect: 
			texture_rect.texture = null
			texture_rect.visible = false
	# If there's a sequence background but no line image, texture_rect visibility is handled by start_dialogue_sequence

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
