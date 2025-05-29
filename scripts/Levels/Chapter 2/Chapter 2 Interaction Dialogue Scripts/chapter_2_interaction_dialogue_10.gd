# chapter_2_interaction_dialogue_10.gd
extends Control

signal dialogue_finished

@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var speaker_label: Label = $SpeakerLabel
@onready var continue_warning_label: Label = $ContinueWarningLabel
@onready var texture_rect: TextureRect = $TextureRect

@onready var player = get_node_or_null("/root/Playground/Player")

# --- DIALOGUE CONTENT FOR DIALOGUE 10 (GOODBYE VIEW) ---
var dialogue_data = {
	"goodbye": {
		"dialogue": [
			{"speaker": "You", "text": "This is it... time to say goodbye."},
			{"speaker": "You", "text": "Thank you all for everything. GRIT, you were an amazing."},
			{"speaker": "You", "text": "URL bots, hope your jobs gets much easier now"},
			{"speaker": "You", "text": "And thank you, little bat, for getting us out of that tower."},
			{"speaker": "GRIT", "text": "The pleasure was all ours. Safe travels, friend."},
			{"speaker": "URL Bot Red", "text": "We'll miss you!"},
			{"speaker": "URL Bot Yellow", "text": "Take care out there!"},
			{"speaker": "URL Bot Blue", "text": "Don't forget about us!"},
			{"speaker": "Bat", "text": "*Sad but encouraging bat sounds*"},
			{"speaker": "You", "text": "I could never forget you all. I hope to see you again soon."},
			{"speaker": "Narrator", "text": "With one last wave, your journey continue to the cosmos.."}
		],
		# Background image showing the view from inside looking outside
		"background_image": "res://textures/Plain Color BG/Sky-Blue.png" # You can replace this with the actual goodbye view image
	}
}
# --- END OF DIALOGUE CONTENT ---

var current_dialogue_lines: Array = []
var current_background_image: String = ""
var current_line_index: int = 0
var typing_speed: float = 0.03
var is_typing: bool = false
var can_proceed: bool = false
var full_current_text: String = ""

var current_sequence_key: String = ""
var dialogue_sequence_keys: Array = ["goodbye"]
var current_sequence_index: int = 0

func _ready() -> void:
	self.visible = false # Start hidden
	if not player:
		printerr("Chapter2InteractionDialogue10: Player node not found. Movement control might fail.")

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
					finish_dialogue()

func start_this_dialogue(sequence_to_play: String = "") -> void:
	if not player:
		printerr("Chapter2InteractionDialogue10: Player node not found when trying to start dialogue.")
	
	if player:
		player.set("can_move", false) # Disable player movement during dialogue

	self.visible = true
	grab_focus()

	rich_text_label.text = ""
	speaker_label.text = ""
	continue_warning_label.visible = false
	texture_rect.visible = false

	current_sequence_index = 0
	var key_to_start = sequence_to_play
	if key_to_start == "" and dialogue_sequence_keys.size() > 0:
		key_to_start = dialogue_sequence_keys[0]
	elif key_to_start == "":
		printerr("Chapter2InteractionDialogue10: No sequence specified and no default sequences available.")
		finish_dialogue()
		return

	start_dialogue_sequence(key_to_start)

func start_dialogue_sequence(sequence_key: String) -> void:
	if not dialogue_data.has(sequence_key):
		printerr("Chapter2InteractionDialogue10: Dialogue sequence key not found: '", sequence_key, "'")
		finish_dialogue()
		return

	current_sequence_key = sequence_key
	current_dialogue_lines = dialogue_data[sequence_key].get("dialogue", [])
	current_background_image = dialogue_data[sequence_key].get("background_image", "")
	current_line_index = 0

	rich_text_label.text = ""
	speaker_label.text = ""
	continue_warning_label.visible = false

	# Set up the background image once at the start of the sequence
	setup_background_image()

	if current_dialogue_lines.size() > 0:
		display_current_line()
	else:
		printerr("Chapter2InteractionDialogue10: Dialogue sequence '", sequence_key, "' has no lines.")
		finish_dialogue()

func setup_background_image() -> void:
	if current_background_image != "":
		if current_background_image.begins_with("res://"):
			var loaded_image = load(current_background_image)
			if loaded_image:
				texture_rect.texture = loaded_image
				texture_rect.visible = true
				# Make the image fill the background properly
				texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
				texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				print("[Chapter2InteractionDialogue10] Background image loaded: ", current_background_image)
			else:
				printerr("Chapter2InteractionDialogue10: Failed to load background image: ", current_background_image)
				texture_rect.visible = false
		else:
			texture_rect.visible = false
	else:
		texture_rect.visible = false

func display_current_line() -> void:
	if current_line_index >= current_dialogue_lines.size():
		return

	var line_data = current_dialogue_lines[current_line_index]
	speaker_label.text = line_data.get("speaker", "Narrator")
	full_current_text = line_data.get("text", "")
	
	# The background image stays visible throughout the entire dialogue sequence
	# No need to change it per line since it's set once in setup_background_image()

	rich_text_label.text = ""
	continue_warning_label.visible = false
	can_proceed = false

	type_text_async(full_current_text)

func type_text_async(text_to_type: String) -> void:
	is_typing = true
	rich_text_label.text = ""
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

func finish_dialogue() -> void:
	print("[Chapter2InteractionDialogue10] Goodbye dialogue finished.")
	if player:
		player.set("can_move", true) # Re-enable player movement after dialogue

	emit_signal("dialogue_finished")
	self.visible = false # Hide the dialogue UI

	# Transition to the next scene or end chapter
	# Replace with your actual next scene path
	var next_scene_path = "res://scenes/Levels/Chapter 2/chapter_2_rocket_travelling_outro.tscn" # Update this path as needed
	var error_code = get_tree().change_scene_to_file(next_scene_path)
	if error_code != OK:
		printerr("Error changing scene to: ", next_scene_path, " - Error code: ", error_code)
