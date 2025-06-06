# chapter_3_rocket_travelling_outro_dialogue.gd
extends Control

signal dialogue_finished

@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var speaker_label: Label = $SpeakerLabel
@onready var continue_warning_label: Label = $ContinueWarningLabel
@onready var texture_rect: TextureRect = $TextureRect
@onready var color_rect: ColorRect = $ColorRect

var dialogue_data = {
	"d_has_chapter_3": {
		"background": "res://textures/Plain Color BG/Sky-Blue.png",
		"dialogue": [
			{"speaker": "Narrator", "text": "Chapter 3 complete! Let's review what you discovered in the mines..."},
			{"speaker": "D", "text": "Beep. I have something for you. Boop."},
			{"speaker": "Narrator", "text": "*Hands you the Chapter 3 of the Django Book*"},
			{"speaker": "You", "text": "Woah!!! OMG We needed this! We didn't know it was on this planet!"},
			{"speaker": "Pip", "text": "Were that lucky I guess, hehe!"},
		]
	},
	"chapter_3_discovery": {
		"background": "",
		"dialogue": [
			{"speaker": "Narrator", "text": "Chapter 3 complete! Let's review what you discovered in the mines..."}
		]
	},
	"models_reflection": {
		"background": "",
		"dialogue": [
			{"speaker": "Narrator", "text": "Django Models are your data structure - they define how information is stored in the database."},
			{"speaker": "Narrator", "text": "Each model class represents a database table, with fields defining the data types."}
		]
	},
	"database_connection": {
		"background": "",
		"dialogue": [
			{"speaker": "Narrator", "text": "Models handle database operations through Django's ORM (Object-Relational Mapping)."},
			{"speaker": "Narrator", "text": "You can create, read, update, and delete data without writing raw SQL queries."}
		]
	},
	"migrations_explanation": {
		"background": "",
		"dialogue": [
			{"speaker": "Narrator", "text": "Django migrations track changes to your models and apply them to the database."},
			{"speaker": "Narrator", "text": "Use 'makemigrations' to create migration files and 'migrate' to apply them."}
		]
	},
	"admin_interface": {
		"background": "",
		"dialogue": [
			{"speaker": "Narrator", "text": "Django's admin interface provides a ready-made way to manage your model data."},
			{"speaker": "Narrator", "text": "Register your models in admin.py to make them accessible through the admin panel."}
		]
	},
	"chapter_completion": {
		"background": "",
		"dialogue": [
			{"speaker": "Pip", "text": "Great work exploring the data mines! Now we understand how Django stores information."},
			{"speaker": "Narrator", "text": "You've mastered Django Models and database management. Chapter 3 complete - onward to new adventures!"}
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
var dialogue_sequences: Array = ["d_has_chapter_3", "chapter_3_discovery", "models_reflection", "database_connection", "migrations_explanation", "admin_interface", "chapter_completion"]

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
	print("[Chapter3RocketTravellingOutroDialogue] Dialogue finished.")
	emit_signal("dialogue_finished")
	visible = false
	
	# Transition to the next scene - update this path as needed
	var next_scene_path = "res://scenes/Hub Area/hub_area.tscn"
	var error_code = get_tree().change_scene_to_file(next_scene_path)
	if error_code != OK:
		printerr("Error changing scene to: ", next_scene_path, " - Error code: ", error_code)
