# chapter_2_interaction_dialogue_6.gd
extends Control

signal dialogue_finished

@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var speaker_label: Label = $SpeakerLabel
@onready var continue_warning_label: Label = $ContinueWarningLabel
@onready var texture_rect: TextureRect = $TextureRect

@onready var player = get_node_or_null("/root/Playground/Player")

# --- DIALOGUE CONTENT FOR DIALOGUE 6 (GRIT MALFUNCTION) ---
var dialogue_data = {
	"malfunction": {
		"dialogue": [
			{"speaker": "GRIT", "text": "ERROR... SYSTEM... MAL-MAL-MALFUNCTION..."},
			{"speaker": "GRIT", "text": "DISPLAY... CORR-CORRUPTED... TEMPLATE... NOT... FOUND..."},
			{"speaker": "GRIT", "text": "ST-ST-STATIC... STYLE... SHEET... MISSING..."},
			
			{"speaker": "URL Bot Red", "text": "Oh no! What happened to GRIT?!"},
			{"spider": "URL Bot Yellow", "text": "Her display is all corrupted!"},
			{"speaker": "URL Bot Blue", "text": "Something's wrong with his visual systems!"},
			
			{"speaker": "URL Bot Red", "text": "You have to fix GRIT's display settings!"},
			{"speaker": "URL Bot Yellow", "text": "She needs his Robot Display Template restored!"},
			{"speaker": "URL Bot Blue", "text": "And his Robot Static Style Sheet too!"},
			
			{"speaker": "URL Bots", "text": "Please help fix GRIT's visual systems!"},
			
			{"speaker": "Narrator", "text": "And so begins the start of the 2ND MINIGAME..."}
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
var dialogue_sequence_keys: Array = ["malfunction"]
var current_sequence_index: int = 0

# Reference to microwave for animation change
@onready var microwave_interactable = get_node_or_null("../../YSortLayer/MicrowaveInteractable")

func _ready() -> void:
	self.visible = false # Start hidden
	if not player:
		printerr("Chapter2InteractionDialogue6: Player node not found. Movement control might fail.")

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
		printerr("Chapter2InteractionDialogue6: Player node not found when trying to start dialogue.")

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
		printerr("Chapter2InteractionDialogue6: No sequence specified and no default sequences available.")
		finish_dialogue()
		return

	start_dialogue_sequence(key_to_start)

func start_dialogue_sequence(sequence_key: String) -> void:
	if not dialogue_data.has(sequence_key):
		printerr("Chapter2InteractionDialogue6: Dialogue sequence key not found: '", sequence_key, "'")
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
		# Trigger microwave death animation when dialogue starts
		trigger_microwave_malfunction()
	else:
		printerr("Chapter2InteractionDialogue6: Dialogue sequence '", sequence_key, "' has no lines.")
		finish_dialogue()

func trigger_microwave_malfunction() -> void:
	# Find the microwave's AnimatedSprite2D and play death animation once
	if microwave_interactable:
		var animated_sprite = microwave_interactable.get_node_or_null("AnimatedSprite2D")
		if animated_sprite:
			animated_sprite.play("death")
			# Connect to animation_finished to stop after one cycle
			if not animated_sprite.animation_finished.is_connected(_on_death_animation_finished):
				animated_sprite.animation_finished.connect(_on_death_animation_finished)
		else:
			printerr("Chapter2InteractionDialogue6: Could not find AnimatedSprite2D in MicrowaveInteractable")
	else:
		printerr("Chapter2InteractionDialogue6: Could not find MicrowaveInteractable")

func _on_death_animation_finished() -> void:
	# Stop the animation after one cycle
	if microwave_interactable:
		var animated_sprite = microwave_interactable.get_node_or_null("AnimatedSprite2D")
		if animated_sprite:
			animated_sprite.stop()

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
				printerr("Chapter2InteractionDialogue6: Failed to load image: ", image_path)
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
	print("[Chapter2InteractionDialogue6] Malfunction dialogue finished.")
	if player:
		player.set("can_move", true) # Re-enable player movement after dialogue

	emit_signal("dialogue_finished")
	self.visible = false # Hide the dialogue UI

	# Transition to the 2nd minigame scene
	var next_scene_path = "res://scenes/Levels/Chapter 2/chapter_2_world_2nd_minigame_pt1.tscn"
	var error_code = get_tree().change_scene_to_file(next_scene_path)
	if error_code != OK:
		printerr("Error changing scene to: ", next_scene_path, " - Error code: ", error_code)
