# chapter_2_interaction_dialogue_5.gd
extends Control

signal dialogue_finished

@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var speaker_label: Label = $SpeakerLabel
@onready var continue_warning_label: Label = $ContinueWarningLabel
@onready var texture_rect: TextureRect = $TextureRect

@onready var player = get_node_or_null("/root/Playground/Player")

# --- DIALOGUE CONTENT FOR DIALOGUE 5 (THANKING PLAYER) ---
var dialogue_data = {
	"gratitude": {
		"dialogue": [
			{"speaker": "URL Bot Red", "text": "You did it! The routes are fixed!"},
			{"speaker": "URL Bot Yellow", "text": "We can navigate the maze so much easier now!"},
			{"speaker": "URL Bot Blue", "text": "Thank you for restoring our pathways to the View Rooms!"},
			
			{"speaker": "GRIT", "text": "Hmph... I have to admit, that was some solid work."},
			{"speaker": "GRIT", "text": "The routing tables are clean, the paths are optimized..."},
			{"speaker": "GRIT", "text": "You actually know what you're doing."},
			
			{"speaker": "URL Bots", "text": "We're so grateful! This makes our deliveries possible again!"},
			{"speaker": "URL Bot Red", "text": "The tower's data flow is restored thanks to you!"},
			
			{"speaker": "GRIT", "text": "Listen, since you helped us out..."},
			{"speaker": "GRIT", "text": "We're gonna help you get out of this dungeon."},
			{"speaker": "GRIT", "text": "I know the way back up to the top of the tower, and with you helping us, we're gonna help you get—"}
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
var dialogue_sequence_keys: Array = ["gratitude"]
var current_sequence_index: int = 0

func _ready() -> void:
	self.visible = true # Start visible for this dialogue
	if not player:
		printerr("Chapter2InteractionDialogue5: Player node not found. Movement control might fail.")
	
	# Start the dialogue automatically
	start_this_dialogue()

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
		printerr("Chapter2InteractionDialogue5: Player node not found when trying to start dialogue.")
	
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
		printerr("Chapter2InteractionDialogue5: No sequence specified and no default sequences available.")
		finish_dialogue()
		return

	start_dialogue_sequence(key_to_start)

func start_dialogue_sequence(sequence_key: String) -> void:
	if not dialogue_data.has(sequence_key):
		printerr("Chapter2InteractionDialogue5: Dialogue sequence key not found: '", sequence_key, "'")
		finish_dialogue()
		return

	current_sequence_key = sequence_key
	current_dialogue_lines = dialogue_data[sequence_key].get("dialogue", [])
	current_image_paths = dialogue_data[sequence_key].get("images", [])
	current_line_index = 0

	rich_text_label.text = ""
	speaker_label.text = ""
	continue_warning_label.visible = false
	texture_rect.visible = false

	if current_dialogue_lines.size() > 0:
		display_current_line()
	else:
		printerr("Chapter2InteractionDialogue5: Dialogue sequence '", sequence_key, "' has no lines.")
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
		if image_path.begins_with("res://"):
			var loaded_image = load(image_path)
			if loaded_image:
				texture_rect.texture = loaded_image
				texture_rect.visible = true
			else:
				printerr("Chapter2InteractionDialogue5: Failed to load image: ", image_path)
				texture_rect.visible = false
		else:
			texture_rect.visible = false
	else:
		texture_rect.visible = false

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
	print("[Chapter2InteractionDialogue5] Gratitude dialogue finished.")
	
	emit_signal("dialogue_finished")
	self.visible = false # Hide this dialogue UI
	
	# Show the next dialogue (Chapter2InteractionDialogue6)
	var dialogue_6 = get_node("../Chapter2InteractionDialogue6")
	if dialogue_6:
		dialogue_6.start_this_dialogue()
	else:
		printerr("Chapter2InteractionDialogue5: Could not find Chapter2InteractionDialogue6")
