# chapter_3_interaction_dialogue_2.gd
extends Control

signal dialogue_finished

@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var speaker_label: Label = $SpeakerLabel
@onready var continue_warning_label: Label = $ContinueWarningLabel
@onready var texture_rect: TextureRect = $TextureRect

# Adjust this path if your player node is located elsewhere or instantiated differently
@onready var player = get_node_or_null("/root/The Mines/Player") # Using get_node_or_null for safety

# --- DIALOGUE CONTENT FOR DIALOGUE 3 ---
# !!! REPLACE THIS WITH YOUR ACTUAL DIALOGUE !!!
var dialogue_data = {
	"initial_greeting_part_1": {
		"dialogue": [
			{"speaker": "You", "text": "Whooo! That was stressful, so many connections and whatnot."},
			{"speaker": "Pip", "text": "Well, at the very least we get to finish it now."},
			{"speaker": "You", "text": "Yep, it was fun though, not gonna lie."},
			{"speaker": "You", "text": "Lets get back to D and tell em we finished the task."},
			{"speaker": "Pip", "text": "Lets goooo!."}
		]
	}
}
# --- END OF DIALOGUE CONTENT ---

var current_dialogue_lines: Array = []
var current_image_paths: Array = []
var current_line_index: int = 0
var typing_speed: float = 0.03
var is_typing: bool = false
var can_proceed: bool = false
var full_current_text: String = ""

var current_sequence_key: String = ""
# Define the sequence(s) this dialogue node will play automatically
var dialogue_sequence_keys: Array = ["initial_greeting_part_1"]
var current_sequence_index: int = 0

func _ready() -> void:
	# Ensure player reference is valid
	if not player:
		printerr("Chapter2InteractionDialogue3: Player node not found at /root/Upper World/Player. Movement will not be disabled/enabled.")

	# Call the public function to start the dialogue
	# This makes it consistent if you ever need to trigger it from elsewhere too.
	start_dialogue()

func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("ui_accept"): # Usually "Enter" or "Space"
		if is_typing:
			is_typing = false # Stop typing
			rich_text_label.text = full_current_text # Show full text immediately
			can_proceed = true
			continue_warning_label.visible = true
		elif can_proceed:
			current_line_index += 1
			if current_line_index < current_dialogue_lines.size():
				display_current_line()
			else:
				# Current sequence finished, try to load the next one
				current_sequence_index += 1
				if current_sequence_index < dialogue_sequence_keys.size():
					start_dialogue_sequence(dialogue_sequence_keys[current_sequence_index])
				else:
					finish_dialogue()

func start_dialogue() -> void:
	self.visible = true
	grab_focus() # Make this control receive input

	if player:
		player.set("can_move", false) # Disable player movement using a property

	rich_text_label.text = ""
	speaker_label.text = ""
	continue_warning_label.visible = false
	texture_rect.visible = false

	if dialogue_sequence_keys.size() > 0:
		current_sequence_index = 0
		start_dialogue_sequence(dialogue_sequence_keys[current_sequence_index])
	else:
		printerr("Chapter3InteractionDialogue1: No dialogue sequences defined!")
		finish_dialogue() # Finish immediately if no sequences

func start_dialogue_sequence(sequence_key: String) -> void:
	if not dialogue_data.has(sequence_key):
		printerr("Chapter3InteractionDialogue1: Dialogue sequence key not found: '", sequence_key, "'")
		finish_dialogue()
		return

	current_sequence_key = sequence_key
	current_dialogue_lines = dialogue_data[sequence_key].get("dialogue", [])
	current_image_paths = dialogue_data[sequence_key].get("images", [])
	current_line_index = 0

	rich_text_label.text = ""
	speaker_label.text = ""
	continue_warning_label.visible = false
	texture_rect.visible = false # Hide texture rect initially

	if current_dialogue_lines.size() > 0:
		display_current_line()
	else:
		printerr("Chapter3InteractionDialogue1: Dialogue sequence '", sequence_key, "' has no lines.")
		finish_dialogue()

func display_current_line() -> void:
	if current_line_index >= current_dialogue_lines.size():
		return

	var line_data = current_dialogue_lines[current_line_index]
	speaker_label.text = line_data.get("speaker", "Narrator")
	full_current_text = line_data.get("text", "")

	# Handle images
	if current_image_paths.size() > current_line_index and current_image_paths[current_line_index] != "":
		var image_path = current_image_paths[current_line_index]
		var loaded_image = load(image_path)
		if loaded_image:
			texture_rect.texture = loaded_image
			texture_rect.visible = true
		else:
			printerr("Chapter3InteractionDialogue1: Failed to load image: ", image_path)
			texture_rect.visible = false
	else:
		texture_rect.visible = false

	rich_text_label.text = ""
	continue_warning_label.visible = false
	can_proceed = false

	type_text_async(full_current_text)

func type_text_async(text_to_type: String) -> void:
	# Stop any existing typing operation first
	is_typing = false
	await get_tree().process_frame  # Wait one frame to ensure cleanup
	
	is_typing = true
	rich_text_label.text = "" # Clear previous text before typing
	
	for char_idx in range(text_to_type.length()):
		if not is_typing: # If player skipped typing
			rich_text_label.text = text_to_type # Instantly show full line
			break
		rich_text_label.text += text_to_type[char_idx]
		await get_tree().create_timer(typing_speed).timeout
		if not is_instance_valid(self): return # Guard against node being freed
	
	if is_instance_valid(self): # Ensure node still exists
		is_typing = false
		can_proceed = true
		continue_warning_label.visible = true

func finish_dialogue() -> void:
	print("[Chapter3InteractionDialogue1] Dialogue finished.")
	if player:
		player.set("can_move", true) # Re-enable player movement

	emit_signal("dialogue_finished")
	self.visible = false
	# queue_free() # Optional: if you want to remove the dialogue node after it's done
