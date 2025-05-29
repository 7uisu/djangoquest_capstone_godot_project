# rocket_travelling_to_chapter_2_world_dialogue.gd
extends Control

signal dialogue_finished

@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var speaker_label: Label = $SpeakerLabel
@onready var continue_warning_label: Label = $ContinueWarningLabel
@onready var texture_rect: TextureRect = $TextureRect
@onready var color_rect: ColorRect = $ColorRect

var dialogue_data = {
	"chapter_2_discovery": {
		"background": "",
		"dialogue": [
			{"speaker": "Narrator", "text": "Chapter 2 complete! Let's review what you discovered..."}
		]
	},
	"url_bots_reflection": {
		"background": "",
		"dialogue": [
			{"speaker": "Narrator", "text": "URL Bots represent Django's URL patterns - pathways connecting web addresses to views."},
			{"speaker": "Narrator", "text": "URLs in urls.py act as traffic controllers, directing requests to the right functions."}
		]
	},
	"views_connection": {
		"background": "",
		"dialogue": [
			{"speaker": "Narrator", "text": "Views are Python functions that receive requests and return responses."},
			{"speaker": "Narrator", "text": "They're the brain of each webpage, processing data and deciding what to display."}
		]
	},
	"grit_static_files": {
		"background": "",
		"dialogue": [
			{"speaker": "Narrator", "text": "GRIT has static files - CSS, JavaScript, images that power your site's appearance."},
			{"speaker": "Narrator", "text": "Tip: Use 'collectstatic' command and STATIC_URL setting to manage them."}
		]
	},
	"templates_explanation": {
		"background": "",
		"dialogue": [
			{"speaker": "Narrator", "text": "GRIT has also Templates are HTML blueprints with Django tags for dynamic content."},
			{"speaker": "Narrator", "text": "Use {{ variables }}, template inheritance, and Django Template Language features."}
		]
	},
	"chapter_completion": {
		"background": "",
		"dialogue": [
			{"speaker": "Pip", "text": "Okay, lets rest for a bit, lets see where we can find the 3rd chapter of the Django Book"},
			{"speaker": "Narrator", "text": "This is Django's MVT architecture. Chapter 2 complete - Adventure awaits you!"}
		]
	}
}

var current_dialogue: Array = []
var dialogue_index: int = 0
var typing_speed: float = 0.03
var is_typing: bool = false
var displaying_text: bool = false
var full_text: String = ""
var current_sequence: int = 0
var dialogue_sequences: Array = ["chapter_2_discovery", "url_bots_reflection", "views_connection", "grit_static_files", "templates_explanation", "chapter_completion"]

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process_input(true)

	rich_text_label.text = ""
	speaker_label.text = ""
	continue_warning_label.visible = false
	
	# Set up the color overlay
	if color_rect:
		color_rect.color = Color(0, 0, 0, 0.3)  # Semi-transparent black overlay
		color_rect.visible = true

	grab_focus()
	start_dialogue(dialogue_sequences[current_sequence])

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and visible:
		if is_typing:
			is_typing = false
			rich_text_label.text = full_text
			continue_warning_label.visible = true
			displaying_text = true
		elif displaying_text:
			dialogue_index += 1

			if dialogue_index >= current_dialogue.size():
				# Move to next dialogue sequence
				current_sequence += 1

				if current_sequence < dialogue_sequences.size():
					dialogue_index = 0
					start_dialogue(dialogue_sequences[current_sequence])
				else:
					finish_dialogue()
			else:
				# Still have more dialogue in current sequence
				display_dialogue_entry()

func start_dialogue(dialogue_key: String) -> void:
	dialogue_index = 0
	is_typing = false
	displaying_text = false
	rich_text_label.text = ""
	speaker_label.text = ""
	continue_warning_label.visible = false

	if dialogue_data.has(dialogue_key):
		var dialogue_set = dialogue_data[dialogue_key]

		# Set background image if specified
		if dialogue_set.has("background") and texture_rect:
			var background_texture = load(dialogue_set["background"])
			if background_texture:
				texture_rect.texture = background_texture
				texture_rect.visible = true
				texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
				texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			else:
				texture_rect.visible = false
		else:
			texture_rect.visible = false

		current_dialogue = dialogue_set["dialogue"]
		visible = true
		display_dialogue_entry()
	else:
		printerr("Dialogue key not found: " + dialogue_key)
		finish_dialogue()

func display_dialogue_entry() -> void:
	if dialogue_index < current_dialogue.size():
		var entry = current_dialogue[dialogue_index]
		speaker_label.text = entry["speaker"]

		full_text = entry["text"]
		rich_text_label.text = ""
		continue_warning_label.visible = false

		type_text(full_text)

func type_text(text_to_type: String) -> void:
	is_typing = true
	displaying_text = false
	rich_text_label.text = ""

	for i in range(text_to_type.length()):
		if not is_typing:
			rich_text_label.text = text_to_type
			break
		rich_text_label.text += text_to_type[i]
		var timer = get_tree().create_timer(typing_speed)
		await timer.timeout
		if not is_instance_valid(self):
			return

	if is_instance_valid(self):
		is_typing = false
		displaying_text = true
		continue_warning_label.visible = true

func finish_dialogue() -> void:
	print("[Chapter2RocketTravellingOutroDialogue] Dialogue finished.")
	emit_signal("dialogue_finished")
	visible = false
	
	# Transition to the next scene - update this path as needed
	var next_scene_path = "res://scenes/Hub Area/hub_area.tscn"
	var error_code = get_tree().change_scene_to_file(next_scene_path)
	if error_code != OK:
		printerr("Error changing scene to: ", next_scene_path, " - Error code: ", error_code)
