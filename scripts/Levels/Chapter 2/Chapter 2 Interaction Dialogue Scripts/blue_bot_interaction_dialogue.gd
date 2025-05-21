#blue_bot_interaction_dialogue.gd
extends Control

signal dialogue_finished

@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var speaker_label: Label = $SpeakerLabel
@onready var continue_warning_label: Label = $ContinueWarningLabel
@onready var texture_rect: TextureRect = $TextureRect
@onready var color_rect: ColorRect = $ColorRect

@onready var player = get_node_or_null("/root/Playground/Player")

var dialogue_data = {
	"blue_bot_info": {
		"dialogue": [
			{"speaker": "URL Bot Blue", "text": "Hi there! I'm the Blue URL Bot, responsible for URL-to-View mapping and advanced Django patterns."},
			{"speaker": "URL Bot Blue", "text": "The people of this place programmed me with knowledge about Django URLs and Views connections, but it's been so long..."},
			{"speaker": "URL Bot Blue", "text": "Django connects URLs to Views through the URLconf defined in urls.py files."},
			{"speaker": "URL Bot Blue", "text": "Each project has a root URLconf, but apps can have their own URLconf files included via 'include()'."},
			{"speaker": "URL Bot Blue", "text": "The 'path()' function maps a URL pattern to a view: path('articles/', views.article_list)."},
			{"speaker": "URL Bot Blue", "text": "For class-based views, use path('articles/', ArticleListView.as_view())."},
			{"speaker": "URL Bot Blue", "text": "URL patterns can capture parts of the URL with named groups: path('articles/<int:year>/', views.year_archive)."},
			{"speaker": "URL Bot Blue", "text": "The captured values are passed to the view as named parameters or in kwargs."},
			{"speaker": "URL Bot Blue", "text": "URL namespaces help organize and reference URL patterns, especially in templates: {% url 'news:archive' %}"},
			{"speaker": "URL Bot Blue", "text": "I miss delivering these patterns to their proper Views Room. If only I could find my way through this maze again..."}
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
		printerr("BlueBotInteractionDialogue: Player node not found. Movement control might fail.")

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
		push_warning("BlueBotInteractionDialogue: start_dialogue called while already active. Ignoring redundant call.")
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
	
	current_dialogue_lines = dialogue_data["blue_bot_info"]["dialogue"]
	current_line_index = 0
	
	is_typing = false # Reset typing state
	can_proceed = false # Reset can_proceed state

	if current_dialogue_lines.size() > 0:
		display_current_line()
	else:
		printerr("BlueBotInteractionDialogue: No dialogue lines found.")
		finish_dialogue()

func display_current_line() -> void:
	if current_line_index >= current_dialogue_lines.size():
		printerr("BlueBotInteractionDialogue: Attempted to display line index out of bounds.") # Added error for consistency
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
