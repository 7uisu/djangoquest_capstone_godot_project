# chapter_3_interaction_dialogue_4.gd
extends Control

signal dialogue_finished

@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var speaker_label: Label = $SpeakerLabel
@onready var continue_warning_label: Label = $ContinueWarningLabel
@onready var texture_rect: TextureRect = $TextureRect
@onready var color_rect: ColorRect = $ColorRect

# Adjust this path if your player node is located elsewhere or instantiated differently
@onready var player = get_node_or_null("/root/The Mines/Player") # Using get_node_or_null for safety

# --- DIALOGUE CONTENT FOR DIALOGUE 4 ---
var dialogue_data = {
	"cute_bot_encounter": {
		"background": "",
		"dialogue": [
			{"speaker": "You", "text": "Uhmm.. Hi? Are you on?"},
			{"speaker": "Cute Monitor", "text": "Warning! Intruders!"},
			{"speaker": "You", "text": "Wait no! we're friendly, we just got stranded to this planet and in need of some resources."},
			{"speaker": "Cute Monitor", "text": "Beep Boop, O K, But we are in need of assistance"},
			{"speaker": "Pip", "text": "Before that, do you have a name?"},
		]
	},
	
	"cute_bot_with_image": {
		"background": "res://textures/Plain Color BG/Sky-Blue.png",
		"dialogue": [
			{"speaker": "Cute Monitor", "text": "Beep Boop, My Name Is D."},
			{"speaker": "You", "text": "Nice to meet you D! Call me traveller, and this is Pip! Anyway, what were you saying?"},
			{"speaker": "Cute Monitor", "text": "Beep Boop, My Name Is D."},
			{"speaker": "Pip", "text": "You already said that, D! Are your memory banks okay?"},
			{"speaker": "Cute Monitor", "text": "System Loop Detected. Recalibrating..."},
			{"speaker": "You", "text": "Looks like D’s having a little hiccup. Let’s give it a moment."},
			{"speaker": "Cute Monitor", "text": "Recalibration Complete. Thank you, Traveller and Pip. As I was saying—"},
		]
	},
	
	"cute_bot_to_corridors": {
		"background": "res://textures/Visual Novel Images/Chapter 1/looking_at_tower.png",
		"dialogue": [
			{"speaker": "Cute Monitor", "text": "This facility has been running autonomously,"},
			{"speaker": "Cute Monitor", "text": "but we're experiencing critical system gaps. We need assistance organizing vital operations."},
			{"speaker": "You", "text": "What kind of operations?"},
			{"speaker": "Cute Monitor", "text": "Three main sectors: Mining, Water Filtering, and Agriculture. Each needs manual oversight to restore full functionality."},
			{"speaker": "Pip", "text": "Ooooh! I love puzzles! Let’s help!"},
			{"speaker": "Cute Monitor", "text": "Just go to those corridors and you'll find the computer for maintaining task."}
		]
	}
}
# --- END OF DIALOGUE CONTENT ---

var current_dialogue_lines: Array = []
var current_line_index: int = 0
var typing_speed: float = 0.03
var is_typing: bool = false
var can_proceed: bool = false
var full_current_text: String = ""
var typing_tween: Tween  # Add this to track the typing animation

var current_sequence_key: String = ""
# Define the sequence(s) this dialogue node will play automatically
var dialogue_sequence_keys: Array = ["cute_bot_encounter","cute_bot_with_image","cute_bot_to_corridors"]
var current_sequence_index: int = 0

func _ready() -> void:
	# Ensure player reference is valid
	if not player:
		printerr("Chapter3InteractionDialogue4: Player node not found at /root/The Mines/Player. Movement will not be disabled/enabled.")
	
	# Set up continue warning label
	if continue_warning_label:
		continue_warning_label.text = "Press SPACE to continue..."
		continue_warning_label.visible = false
	
	# Set Z-index for proper layering (background should be behind everything)
	if texture_rect:
		texture_rect.z_index = -2  # Background image behind everything
	if color_rect:
		color_rect.z_index = -1    # Dark overlay above background
	if rich_text_label:
		rich_text_label.z_index = 1  # Dialogue text on top
	if speaker_label:
		speaker_label.z_index = 1   # Speaker text on top
	if continue_warning_label:
		continue_warning_label.z_index = 1  # Warning text on top
	
	# Hide initially
	self.visible = false

func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("ui_accept"): # Usually "Enter" or "Space"
		if is_typing:
			# Stop typing animation immediately
			stop_typing()
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

func stop_typing() -> void:
	"""Stop any ongoing typing animation safely"""
	is_typing = false
	if typing_tween:
		typing_tween.kill()
		typing_tween = null

func start_dialogue() -> void:
	self.visible = true
	grab_focus() # Make this control receive input

	if player:
		player.set("can_move", false) # Disable player movement using a property

	# Stop any existing typing first
	stop_typing()
	
	rich_text_label.text = ""
	speaker_label.text = ""
	continue_warning_label.visible = false
	texture_rect.visible = true # Show background image
	color_rect.visible = true   # Show dark overlay

	if dialogue_sequence_keys.size() > 0:
		current_sequence_index = 0
		start_dialogue_sequence(dialogue_sequence_keys[current_sequence_index])
	else:
		printerr("Chapter3InteractionDialogue4: No dialogue sequences defined!")
		finish_dialogue() # Finish immediately if no sequences

func start_dialogue_sequence(sequence_key: String) -> void:
	if not dialogue_data.has(sequence_key):
		printerr("Chapter3InteractionDialogue4: Dialogue sequence key not found: '", sequence_key, "'")
		finish_dialogue()
		return

	# Stop any existing typing first
	stop_typing()

	current_sequence_key = sequence_key
	current_dialogue_lines = dialogue_data[sequence_key].get("dialogue", [])
	current_line_index = 0

	rich_text_label.text = ""
	speaker_label.text = ""
	continue_warning_label.visible = false

	# Set background image if specified
	var dialogue_info = dialogue_data[sequence_key]
	if "background" in dialogue_info and texture_rect:
		var background_texture = load(dialogue_info["background"])
		if background_texture:
			texture_rect.texture = background_texture
			texture_rect.visible = true
		else:
			print("Warning: Could not load background image: ", dialogue_info["background"])
			texture_rect.visible = false
	else:
		texture_rect.visible = false

	if current_dialogue_lines.size() > 0:
		display_current_line()
	else:
		printerr("Chapter3InteractionDialogue4: Dialogue sequence '", sequence_key, "' has no lines.")
		finish_dialogue()

func display_current_line() -> void:
	if current_line_index >= current_dialogue_lines.size():
		return

	# Stop any existing typing first
	stop_typing()

	var line_data = current_dialogue_lines[current_line_index]
	speaker_label.text = line_data.get("speaker", "Narrator")
	full_current_text = line_data.get("text", "")

	rich_text_label.text = ""
	continue_warning_label.visible = false
	can_proceed = false

	type_text_async(full_current_text)

func type_text_async(text_to_type: String) -> void:
	# Stop any existing typing operation first
	stop_typing()
	
	# Clear the text completely before starting
	rich_text_label.text = ""
	is_typing = true
	
	# Use a more reliable method with character-by-character display
	for i in range(text_to_type.length()):
		if not is_typing or not is_instance_valid(self):
			break
		
		# Set the text to show only up to current character
		rich_text_label.text = text_to_type.substr(0, i + 1)
		
		# Wait for the typing delay
		await get_tree().create_timer(typing_speed).timeout
	
	# Ensure we show the complete text and finish properly
	if is_instance_valid(self):
		is_typing = false
		can_proceed = true
		rich_text_label.text = text_to_type  # Ensure full text is shown
		continue_warning_label.visible = true

func finish_dialogue() -> void:
	print("[Chapter3InteractionDialogue4] Dialogue finished.")
	
	# Stop any ongoing typing
	stop_typing()
	
	if player:
		player.set("can_move", true) # Re-enable player movement

	emit_signal("dialogue_finished")
	self.visible = false

# Legacy function for compatibility with your existing code
func show_dialogue(dialogue_key: String) -> void:
	if dialogue_key in dialogue_data:
		dialogue_sequence_keys = [dialogue_key]
		start_dialogue()
	else:
		print("Dialogue key not found: ", dialogue_key)
