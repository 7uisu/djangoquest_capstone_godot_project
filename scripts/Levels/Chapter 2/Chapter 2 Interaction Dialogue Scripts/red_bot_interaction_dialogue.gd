#red_bot_interaction_dialogue.gd
extends Control

signal dialogue_finished

@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var speaker_label: Label = $SpeakerLabel
@onready var continue_warning_label: Label = $ContinueWarningLabel
@onready var texture_rect: TextureRect = $TextureRect
@onready var color_rect: ColorRect = $ColorRect

@onready var player = get_node_or_null("/root/Playground/Player")

var dialogue_data = {
	"red_bot_info": {
		"dialogue": [
			{"speaker": "URL Bot Red", "text": "Hello there! I'm the Red URL Bot, responsible for delivering accurate URL patterns to the Views Room."},
			{"speaker": "URL Bot Red", "text": "The people of this place programmed me with knowledge about Django URLs, but I can't quite remember what it all means now..."},
			{"speaker": "URL Bot Red", "text": "URLs in Django follow a pattern-matching system. Each URL pattern is defined in the urls.py file."},
			{"speaker": "URL Bot Red", "text": "URL patterns connect specific URLs to view functions. For example, 'path('articles/<int:year>/', views.year_archive)' routes to the year_archive view."},
			{"speaker": "URL Bot Red", "text": "URL patterns can include converters like <int:year> to capture and convert parts of the URL path."},
			{"speaker": "URL Bot Red", "text": "Common converters include 'str', 'int', 'slug', 'uuid', and 'path', each ensuring the parameter is of the correct type."},
			{"speaker": "URL Bot Red", "text": "Django processes URL patterns in order, stopping at the first match. Order matters!"},
			{"speaker": "URL Bot Red", "text": "That's all I remember for now. If only I could find my way back to the Views Room..."}
		]
	}
}

var current_dialogue_lines: Array = []
var current_line_index: int = 0
var typing_speed: float = 0.03
var is_typing: bool = false
var can_proceed: bool = false
var full_current_text: String = ""
var is_dialogue_active: bool = false

func _ready() -> void:
	self.visible = false
	if not player:
		printerr("RedBotInteractionDialogue: Player node not found. Movement control might fail.")

func _input(event: InputEvent) -> void:
	if not visible or not is_dialogue_active:
		return

	if event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
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
	if is_dialogue_active:
		# Changed to push_warning
		push_warning("RedBotInteractionDialogue: start_dialogue called while already active. Ignoring redundant call.")
		return

	is_dialogue_active = true

	if player and "can_move" in player:
		player.can_move = false
	
	self.visible = true
	grab_focus()
	
	rich_text_label.text = ""
	speaker_label.text = ""
	continue_warning_label.visible = false
	texture_rect.visible = false
	
	current_dialogue_lines = dialogue_data["red_bot_info"]["dialogue"]
	current_line_index = 0
	
	is_typing = false
	can_proceed = false

	if current_dialogue_lines.size() > 0:
		display_current_line()
	else:
		printerr("RedBotInteractionDialogue: No dialogue lines found for 'red_bot_info'.")
		finish_dialogue()

func display_current_line() -> void:
	if current_line_index >= current_dialogue_lines.size():
		printerr("RedBotInteractionDialogue: Attempted to display line index out of bounds.")
		finish_dialogue()
		return

	var line_data = current_dialogue_lines[current_line_index]
	speaker_label.text = line_data.get("speaker", "Narrator")
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
		rich_text_label.text = text_to_type
		can_proceed = true
		continue_warning_label.visible = true

func finish_dialogue() -> void:
	if player and "can_move" in player:
		player.can_move = true
	
	emit_signal("dialogue_finished")
	self.visible = false
	is_dialogue_active = false
	is_typing = false
	can_proceed = false
