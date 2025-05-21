#pip_cat_interaction_dialogue.gd
extends Control

signal dialogue_finished

@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var speaker_label: Label = $SpeakerLabel
@onready var continue_warning_label: Label = $ContinueWarningLabel
@onready var texture_rect: TextureRect = $TextureRect
@onready var color_rect: ColorRect = $ColorRect

@onready var player = get_node_or_null("/root/Playground/Player")

var dialogue_data = {
	"pip_cat_info": {
		"dialogue": [
			{"speaker": "Pip Cat", "text": "Meow! I'm Pip Cat, your trusty coding companion!"},
			{"speaker": "Pip Cat", "text": "These URL Bots are quite fascinating, aren't they? Each one carries specialized knowledge about Django's URL routing system."},
			{"speaker": "Pip Cat", "text": "See that microwave-looking bot? That's GRIT. Don't mind the grumpy face—that's just how he built him."},
			{"speaker": "Pip Cat", "text": "GRIT manages all the routing tables for the URL Bots. Without him, the entire system would fall apart."},
			{"speaker": "Pip Cat", "text": "I've been exploring this tower for a while. The way Django connects URLs to Views is brilliant engineering."},
			{"speaker": "Pip Cat", "text": "Have you checked the bulletin board yet? There might be some useful information there about this level."},
			{"speaker": "Pip Cat", "text": "When you're ready for the challenge, talk to GRIT. He'll explain how to help the URL Bots find their way to their Views Rooms."},
			{"speaker": "Pip Cat", "text": "I'll be around if you need any hints or encouragement. Meow!"}
		]
	}
}

var current_dialogue_lines: Array = []
var current_line_index: int = 0
var typing_speed: float = 0.03
var is_typing: bool = false
var can_proceed: bool = false
var full_current_text: String = ""
var is_dialogue_active: bool = false # Added to mirror other scripts

func _ready() -> void:
	self.visible = false
	if not player:
		printerr("PipCatInteractionDialogue: Player node not found. Movement control might fail.")

func _input(event: InputEvent) -> void:
	if not visible or not is_dialogue_active: # Added is_dialogue_active check
		return

	if event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled() # Good practice
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
				finish_dialogue()

func start_dialogue() -> void:
	if is_dialogue_active: # Added to mirror other scripts
		push_warning("PipCatInteractionDialogue: start_dialogue called while already active. Ignoring redundant call.")
		return

	is_dialogue_active = true # Set active when dialogue starts
	
	if player and "can_move" in player:
		player.can_move = false
	
	self.visible = true
	grab_focus()
	
	rich_text_label.text = ""
	speaker_label.text = ""
	continue_warning_label.visible = false
	texture_rect.visible = false
	
	current_dialogue_lines = dialogue_data["pip_cat_info"]["dialogue"]
	current_line_index = 0
	
	is_typing = false # Reset typing state
	can_proceed = false # Reset can_proceed state

	if current_dialogue_lines.size() > 0:
		display_current_line()
	else:
		printerr("PipCatInteractionDialogue: No dialogue lines found.")
		finish_dialogue()

func display_current_line() -> void:
	if current_line_index >= current_dialogue_lines.size():
		printerr("PipCatInteractionDialogue: Attempted to display line index out of bounds.") # Added error for consistency
		finish_dialogue()
		return

	var line_data = current_dialogue_lines[current_line_index]
	speaker_label.text = line_data.get("speaker", "Narrator") # Changed default speaker to "Narrator" for consistency
	full_current_text = line_data.get("text", "")
	
	rich_text_label.text = ""
	continue_warning_label.visible = false
	can_proceed = false
	
	type_text_async(full_current_text)

func type_text_async(text_to_type: String) -> void:
	is_typing = true
	
	for char_idx in range(text_to_type.length()):
		if not is_typing:
			rich_text_label.text = text_to_type
			break
		
		rich_text_label.text += text_to_type[char_idx]
		await get_tree().create_timer(typing_speed).timeout
		
		if not is_instance_valid(self):
			return

	if is_instance_valid(self):
		is_typing = false
		rich_text_label.text = text_to_type # Ensure full text is displayed
		can_proceed = true
		continue_warning_label.visible = true

func finish_dialogue() -> void:
	if player and "can_move" in player:
		player.can_move = true
	
	emit_signal("dialogue_finished")
	self.visible = false
	is_dialogue_active = false # Set inactive when dialogue finishes
	is_typing = false # Reset typing state
	can_proceed = false # Reset can_proceed state
