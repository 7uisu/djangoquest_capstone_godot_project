# rocket_travelling_to_chapter_2_world.gd
extends Control

signal dialogue_finished

@onready var rich_text_label = $RocketTravellingToChapter2WorldDialogue/RichTextLabel
@onready var speaker_label = $RocketTravellingToChapter2WorldDialogue/SpeakerLabel
@onready var continue_warning_label = $RocketTravellingToChapter2WorldDialogue/ContinueWarningLabel
@onready var texture_rect = $RocketTravellingToChapter2WorldDialogue/TextureRect
@onready var color_rect = $RocketTravellingToChapter2WorldDialogue/ColorRect
@onready var fire2 = $Fire2

var dialogue_data = {
	"rocket_travel_intro": {
		"dialogue": [
			{"speaker": "Narrator", "text": "On our way to finding Chapter 2 of the Django Book!"},
			{"speaker": "Pip", "text": "Chapter 1 was intense... I wonder what’s next."},
			{"speaker": "You", "text": "Hopefully fewer errors and more learning!"},
			{"speaker": "Narrator", "text": "The rocket hums gently as stars blur past your window..."}
		]
	},
	"tower_sighting": {
		"background": "res://textures/Nature & village pack/containers & tents/Containers/Animations/blue/normal/Down/Close_Down_blue.png",
		"dialogue": [
			{"speaker": "Pip", "text": "Look! That's a pretty tall tower ahead."},
			{"speaker": "You", "text": "It stands out even from here. We’ll try to land there."},
			{"speaker": "Narrator", "text": "Clouds swirl around the structure, reflecting the light from your rocket."},
			{"speaker": "Pip", "text": "Do you think it's part of the Chapter 2 tutorial zone?"},
			{"speaker": "You", "text": "Only one way to find out. Initiating descent!"}
		]
	},
	"rocket_landing": {
		"background": "res://textures/Plain Color BG/Sky-Blue.png",
		"dialogue": [
			{"speaker": "Narrator", "text": "With a gentle rumble, the rocket slows its approach."},
			{"speaker": "Pip", "text": "Landing sequence initiated. Hang tight!"},
			{"speaker": "You", "text": "Stabilizers holding... touchdown in 3... 2... 1..."},
			{"speaker": "Narrator", "text": "The rocket touches down smoothly atop the tower."},
			{"speaker": "Pip", "text": "Nice! Let’s see what Chapter 2 has in store for us."}
		]
	}
}

var current_dialogue = []
var dialogue_index = 0
var typing_speed = 0.03
var is_typing = false
var displaying_text = false
var full_text = ""
var current_sequence = 0
var dialogue_sequences = ["rocket_travel_intro", "tower_sighting", "rocket_landing"]


func _ready():
	if fire2:
		fire2.play("default")
	else:
		printerr("Fire2 node not found!")

	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process_input(true)

	rich_text_label.text = ""
	speaker_label.text = ""
	continue_warning_label.visible = false

	grab_focus()

	start_dialogue(dialogue_sequences[current_sequence])

	connect("dialogue_finished", Callable(self, "_on_dialogue_finished"))


func _input(event):
	if event.is_action_pressed("ui_accept") and visible:
		if is_typing:
			is_typing = false
			rich_text_label.text = full_text
			continue_warning_label.visible = true
			displaying_text = true
		elif displaying_text:
			dialogue_index += 1

			if dialogue_index >= current_dialogue.size():
				current_sequence += 1

				if current_sequence < dialogue_sequences.size():
					dialogue_index = 0
					start_dialogue(dialogue_sequences[current_sequence])
				else:
					emit_signal("dialogue_finished")
					visible = false
			else:
				display_dialogue_entry()

func start_dialogue(dialogue_key):
	dialogue_index = 0
	is_typing = false
	displaying_text = false
	rich_text_label.text = ""
	speaker_label.text = ""
	continue_warning_label.visible = false

	if dialogue_data.has(dialogue_key):
		var dialogue_set = dialogue_data[dialogue_key]

		if dialogue_set.has("background") and texture_rect:
			var background_texture = load(dialogue_set["background"])
			if background_texture:
				texture_rect.texture = background_texture
				texture_rect.visible = true
			else:
				texture_rect.visible = false
		else:
			texture_rect.visible = false

		current_dialogue = dialogue_set["dialogue"]
		visible = true
		display_dialogue_entry()
	else:
		push_error("Dialogue key not found: " + dialogue_key)
		emit_signal("dialogue_finished")

func display_dialogue_entry():
	if dialogue_index < current_dialogue.size():
		var entry = current_dialogue[dialogue_index]
		speaker_label.text = entry["speaker"]

		full_text = entry["text"]
		rich_text_label.text = ""
		continue_warning_label.visible = false

		type_text(full_text)
	else:
		pass

func type_text(text_to_type) -> void:
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

	is_typing = false
	displaying_text = true
	continue_warning_label.visible = true

func _on_dialogue_finished():
	get_tree().change_scene_to_file("res://scenes/Levels/Chapter 2/chapter_2_world_part_1.tscn")
