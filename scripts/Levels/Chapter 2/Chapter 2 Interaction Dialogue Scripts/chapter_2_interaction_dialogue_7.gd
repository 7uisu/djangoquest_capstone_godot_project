# chapter_2_interaction_dialogue_7.gd
extends Control

signal dialogue_finished

@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var speaker_label: Label = $SpeakerLabel
@onready var continue_warning_label: Label = $ContinueWarningLabel
@onready var texture_rect: TextureRect = $TextureRect

@onready var player = get_node_or_null("/root/Playground/Player")
@onready var bat = get_node_or_null("../../Bat")

# --- DIALOGUE CONTENT FOR DIALOGUE 7 (GRIT RECOVERED) ---
var dialogue_data = {
	"recovery": {
		"dialogue": [
			{"speaker": "GRIT", "text": "Ah... systems restored. Display functioning normally."},
			{"speaker": "GRIT", "text": "Thank you for repairing my visual components."},
			{"speaker": "GRIT", "text": "Though it didn't fix my facial expression... still stuck with this angry look."},
			{"speaker": "GRIT", "text": "But don't worry - that's not how I actually feel. I'm quite grateful, actually."},
			
			{"speaker": "URL Bot Red", "text": "GRIT! You're back to normal!"},
			{"speaker": "URL Bot Yellow", "text": "We're so glad you're okay!"},
			{"speaker": "URL Bot Blue", "text": "Thank you for fixing our friend!"},
			{"speaker": "URL Bots", "text": "We couldn't have done it without you!"},
			
			{"speaker": "GRIT", "text": "Now, as promised, let me teach you how to get out of this dungeon."},
			{"speaker": "GRIT", "text": "The secret is... you need to ride a bat."},
			{"speaker": "You", "text": "A bat? Seriously?"},
			{"speaker": "GRIT", "text": "Trust me on this one. They know all the air currents in the tower."},
			{"speaker": "GRIT", "text": "Hey! Bat friend! Come over here!"},
			{"speaker": "GRIT", "text": "Perfect! Here's your ride. Come on, let's go!"},
			{"speaker": "You", "text": "Uhm.. where do we sit?"},
			{"speaker": "GRIT", "text": "At the back? trust us! We had no reason to ride out of this place"},
			{"speaker": "GRIT", "text": "But now we do, so let's go!"},
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
var dialogue_sequence_keys: Array = ["recovery"]
var current_sequence_index: int = 0

var bat_called: bool = false

func _ready() -> void:
	self.visible = true # Start visible for this dialogue
	if not player:
		printerr("Chapter2InteractionDialogue7: Player node not found. Movement control might fail.")
	if not bat:
		printerr("Chapter2InteractionDialogue7: Bat node not found.")
	
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
			# Check if we need to call the bat
			if current_line_index == 11 and not bat_called: # "Hey! Bat friend! Come over here!"
				call_bat()
				bat_called = true
			
			current_line_index += 1
			if current_line_index < current_dialogue_lines.size():
				display_current_line()
			else:
				current_sequence_index += 1
				if current_sequence_index < dialogue_sequence_keys.size():
					start_dialogue_sequence(dialogue_sequence_keys[current_sequence_index])
				else:
					finish_dialogue()

func call_bat() -> void:
	if bat:
		print("Calling bat to move from x 1334.0 y -422.0 to x 779.0")
		# Move bat from position x 1334.0 y -422.0 to x 779.0 (keeping same y)
		var tween = create_tween()
		tween.tween_property(bat, "position", Vector2(779.0, -422.0), 2.0)
		tween.tween_callback(func(): print("Bat arrived at destination"))

func start_this_dialogue(sequence_to_play: String = "") -> void:
	if not player:
		printerr("Chapter2InteractionDialogue7: Player node not found when trying to start dialogue.")
	
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
		printerr("Chapter2InteractionDialogue7: No sequence specified and no default sequences available.")
		finish_dialogue()
		return

	start_dialogue_sequence(key_to_start)

func start_dialogue_sequence(sequence_key: String) -> void:
	if not dialogue_data.has(sequence_key):
		printerr("Chapter2InteractionDialogue7: Dialogue sequence key not found: '", sequence_key, "'")
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
		printerr("Chapter2InteractionDialogue7: Dialogue sequence '", sequence_key, "' has no lines.")
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
				printerr("Chapter2InteractionDialogue7: Failed to load image: ", image_path)
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
	print("[Chapter2InteractionDialogue7] Recovery dialogue finished.")
	
	emit_signal("dialogue_finished")
	self.visible = false # Hide this dialogue UI
	
	# Show the next dialogue (Chapter2InteractionDialogue8)
	var dialogue_8 = get_node("../Chapter2InteractionDialogue8")
	if dialogue_8:
		dialogue_8.start_this_dialogue()
	else:
		printerr("Chapter2InteractionDialogue7: Could not find Chapter2InteractionDialogue8")
