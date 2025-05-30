# chapter_2_interaction_dialogue_9.gd
extends Control

signal dialogue_finished

@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var speaker_label: Label = $SpeakerLabel
@onready var continue_warning_label: Label = $ContinueWarningLabel
@onready var texture_rect: TextureRect = $TextureRect

@onready var player = get_node_or_null("/root/Playground/Player")

# --- DIALOGUE CONTENT FOR DIALOGUE 9 (TOP OF TOWER) ---
var dialogue_data = {
	"tower_top": {
		"dialogue": [
			{"speaker": "You", "text": "Hey, we're at the top of the tower now!"},
			{"speaker": "URL Bot Red", "text": "Thank you again for everything you've done for us!"},
			{"speaker": "URL Bot Yellow", "text": "You fixed our routes!"},
			{"speaker": "GRIT", "text": "And you fixed me!"},
			{"speaker": "URL Bot Blue", "text": "We wish we could ride the rocket with you someday!"},
			{"speaker": "GRIT", "text": "Perhaps our paths will cross again in the stars."},
			{"speaker": "You", "text": "I hope so too. You've all been amazing friends."},
			{"speaker": "Bat", "text": "*Happy bat noises*"},
			{"speaker": "GRIT", "text": "Now go, your rocket awaits. Adventure is calling!"}
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

var current_sequence_key: String = ""
var dialogue_sequence_keys: Array = ["tower_top"]
var current_sequence_index: int = 0

func _ready() -> void:
	self.visible = false # Start hidden
	if not player:
		printerr("Chapter2InteractionDialogue9: Player node not found. Movement control might fail.")

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
		printerr("Chapter2InteractionDialogue9: Player node not found when trying to start dialogue.")
	
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
		printerr("Chapter2InteractionDialogue9: No sequence specified and no default sequences available.")
		finish_dialogue()
		return

	start_dialogue_sequence(key_to_start)

func start_dialogue_sequence(sequence_key: String) -> void:
	if not dialogue_data.has(sequence_key):
		printerr("Chapter2InteractionDialogue9: Dialogue sequence key not found: '", sequence_key, "'")
		finish_dialogue()
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
		printerr("Chapter2InteractionDialogue9: Dialogue sequence '", sequence_key, "' has no lines.")
		finish_dialogue()

func display_current_line() -> void:
	if current_line_index >= current_dialogue_lines.size():
		return

	var line_data = current_dialogue_lines[current_line_index]
	speaker_label.text = line_data.get("speaker", "Narrator")
	full_current_text = line_data.get("text", "")
	
	# No background images for this dialogue
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
	print("[Chapter2InteractionDialogue9] Tower top dialogue finished.")
	
	emit_signal("dialogue_finished")
	self.visible = false # Hide this dialogue UI
	
	# Show the next dialogue (Chapter2InteractionDialogue10)
	var dialogue_10 = get_node("../Chapter2InteractionDialogue10")
	if dialogue_10:
		dialogue_10.start_this_dialogue()
	else:
		printerr("Chapter2InteractionDialogue9: Could not find Chapter2InteractionDialogue10")
