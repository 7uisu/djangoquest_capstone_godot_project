# chapter_2_interaction_dialogue_4.gd
extends Control

signal dialogue_finished

@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var speaker_label: Label = $SpeakerLabel
@onready var continue_warning_label: Label = $ContinueWarningLabel
@onready var texture_rect: TextureRect = $TextureRect

@onready var player = get_node_or_null("/root/Playground/Player")

# --- DIALOGUE CONTENT FOR DIALOGUE 4 (CUTSCENE) ---
# !!! REPLACE THIS WITH YOUR ACTUAL DIALOGUE !!!
var dialogue_data = {
	"cutscene_reveal": {
		"dialogue": [
			{"speaker": "Narrator", "text": "As the darkness fades, soft lights flicker on in a wide, dusty chamber."},
			{"speaker": "Narrator", "text": "Three delivery bots are in front of you. A fourth, shaped like an angry microwave, stands in the middle."},

			{"speaker": "MicrowaveBot", "text": "Tch. Another visitor."},
			{"speaker": "You", "text": "Hi...?"},
			{"speaker": "MicrowaveBot", "text": "Ignore the face. I was built like this. Not actually mad—usually."},

			{"speaker": "URL Bots", "text": "We are the URL Delivery Bots! We delivered data to the tower’s View Rooms."},
			{"speaker": "URL Bot Blue", "text": "But everyone’s gone. We forgot the maze routes to our rooms."},

			{"speaker": "You", "text": "And you? What’s your deal?"},
			{"speaker": "MicrowaveBot", "text": "Name’s GRIT—General-purpose Reactive Interface Terminal. I managed their routing tables, served up the templates and static resources they needed to function."},
			{"speaker": "GRIT", "text": "No templates, no deliveries. I kept the tower running. Now I just... sit here and hum."},

			{"speaker": "You", "text": "So this is all that’s left of the tower?"},
			{"speaker": "GRIT", "text": "Yup. Four bots and a spaghetti maze of broken paths."},
			{"speaker": "Pip", "text": "Maybe we can help restore the routes."},
			{"speaker": "You", "text": "Let’s map it out and bring everything back online."},
			{"speaker": "GRIT", "text": "Hmph... not like I care or anything... but—fine. Good luck out there, rookies."}
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
# This dialogue node will typically play one sequence when triggered
var dialogue_sequence_keys: Array = ["cutscene_reveal"] # Default sequence if started generically
var current_sequence_index: int = 0

func _ready() -> void:
	self.visible = false # Start hidden, will be shown by trigger
	if not player:
		printerr("Chapter2InteractionDialogue4: Player node not found. Movement control might fail.")

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

# Public method to be called by the trigger
func start_this_dialogue(sequence_to_play: String = "") -> void:
	if not player:
		printerr("Chapter2InteractionDialogue4: Player node not found when trying to start dialogue.")
		# Decide if dialogue should proceed or not without player reference.
		# For now, we'll let it proceed but movement won't be controlled.
	# Player movement should already be disabled by the trigger before this is called.

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
		printerr("Chapter2InteractionDialogue4: No sequence specified and no default sequences available.")
		finish_dialogue() # This will now also attempt scene change if called early
		return

	start_dialogue_sequence(key_to_start)

func start_dialogue_sequence(sequence_key: String) -> void:
	if not dialogue_data.has(sequence_key):
		printerr("Chapter2InteractionDialogue4: Dialogue sequence key not found: '", sequence_key, "'")
		finish_dialogue() # This will now also attempt scene change
		return

	current_sequence_key = sequence_key
	current_dialogue_lines = dialogue_data[sequence_key].get("dialogue", [])
	current_image_paths = dialogue_data[sequence_key].get("images", []) # Make sure this line exists
	current_line_index = 0

	rich_text_label.text = ""
	speaker_label.text = ""
	continue_warning_label.visible = false
	texture_rect.visible = false

	if current_dialogue_lines.size() > 0:
		display_current_line()
	else:
		printerr("Chapter2InteractionDialogue4: Dialogue sequence '", sequence_key, "' has no lines.")
		finish_dialogue() # This will now also attempt scene change

func display_current_line() -> void:
	if current_line_index >= current_dialogue_lines.size():
		return

	var line_data = current_dialogue_lines[current_line_index]
	speaker_label.text = line_data.get("speaker", "Narrator")
	full_current_text = line_data.get("text", "")
	
	# Handle images
	if current_image_paths.size() > current_line_index and current_image_paths[current_line_index] != "" :
		var image_path = current_image_paths[current_line_index]
		# Ensure the path is valid, e.g., starts with "res://"
		if image_path.begins_with("res://"):
			var loaded_image = load(image_path)
			if loaded_image:
				texture_rect.texture = loaded_image
				texture_rect.visible = true
			else:
				printerr("Chapter2InteractionDialogue4: Failed to load image: ", image_path)
				texture_rect.visible = false
		else:
			# printerr("Chapter2InteractionDialogue4: Invalid image path (must start with res://): ", image_path) # Optional: more specific error
			texture_rect.visible = false # Hide if path is not a resource path or is empty
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
	print("[Chapter2InteractionDialogue4] Cutscene dialogue finished.")
	if player:
		player.set("can_move", true) # Re-enable player movement after this dialogue

	emit_signal("dialogue_finished")
	self.visible = false # Hide the dialogue UI

	# Optional: queue_free() # If you want to remove the dialogue node from the scene tree

	# Transition to the next scene
	var next_scene_path = "res://scenes/Levels/Chapter 2/chapter_2_world_part_4.tscn"
	var error_code = get_tree().change_scene_to_file(next_scene_path)
	if error_code != OK:
		printerr("Error changing scene to: ", next_scene_path, " - Error code: ", error_code)
