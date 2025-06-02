# rocket_travelling_to_chapter_3_world.gd
extends Control

signal dialogue_finished

@onready var rich_text_label = $RocketTravellingToChapter3WorldDialogue/RichTextLabel
@onready var speaker_label = $RocketTravellingToChapter3WorldDialogue/SpeakerLabel
@onready var continue_warning_label = $RocketTravellingToChapter3WorldDialogue/ContinueWarningLabel
@onready var texture_rect = $RocketTravellingToChapter3WorldDialogue/TextureRect
@onready var color_rect = $RocketTravellingToChapter3WorldDialogue/ColorRect
@onready var fire2 = $Fire2

var dialogue_data = {
	"rocket_travel_intro": {
		"dialogue": [
			{"speaker": "Narrator", "text": "On our way to finding Chapter 3 of the Django Book!"},
			{"speaker": "Pip", "text": "Chapter 2 was very wonderful, we met some new friends."},
			{"speaker": "You", "text": "I winder what they are doing right now?"},
			{"speaker": "Narrator", "text": "As you and Pip was reminiscing, your terminal suddenly talks.."}
		]
	},
	"tower_sighting": {
		"background": "res://textures/Visual Novel Images/Chapter 1/looking_at_tower.png",
		"dialogue": [
			{
				"speaker": "Terminal", "text": "CRITICAL WARNING: Fuel reserves at zero. Emergency landing sequence initiated! Brace for impact!"
			}, {
				"speaker": "You", "text": "What?! Zero?! Pip, find us a landing site, *now*! Anything!"
			}, {
				"speaker": "Pip", "text": "Got one! Displaying on screen... It's designated as 'Planet Resource-X,' looks promising!"
			}, {
				"speaker": "You", "text": "Resource-X, huh? Sounds like our kind of place. Terminal, full power to retro-thrusters! Prepare for atmospheric entry!"
			}, {
				"speaker": "Terminal", "text": "Affirmative. Commencing landing sequence. High g-forces expected."
			}
		]
	},
	"rocket_landing": {
		"background": "res://textures/Plain Color BG/Sky-Blue.png",
		"dialogue": [
			{
				"speaker": "Narrator", "text": "The ship shuddered violently as it plunged through the atmosphere, the hull groaning under the immense strain."
			}, {
				"speaker": "You", "text": "Hold on tight! Just a little further... easy does it!"
			}, {
				"speaker": "Pip", "text": "Altitude rapidly decreasing! Approaching ground level... five hundred feet... two hundred... fifty..."
			}, {
				"speaker": "Terminal", "text": "Touchdown. All systems green. Landing successful."
			}, {
				"speaker": "You", "text": "Phew! That was too close for comfort. Good job, team. We made it."
			}, {
				"speaker": "Pip", "text": "We're safe! But... the power readings are almost nonexistent. We won't be flying anywhere soon."
			}, {
				"speaker": "You", "text": "Right. Check the life support systems, Pip. We also need to find food and water, and fast. 'Resource-X' better live up to its name."
			}, {
				"speaker": "Narrator", "text": "Stranded on an unknown world, the immediate relief of landing was quickly replaced by the pressing need for survival."
			}
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
	get_tree().change_scene_to_file("res://scenes/Levels/Chapter 3 (5-24-25)/Story Flow World 3/chapter_3_world_part_1.tscn")
