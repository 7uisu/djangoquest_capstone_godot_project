extends Control

signal ready_selected
signal not_ready_selected

@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var speaker_label: Label = $SpeakerLabel
@onready var continue_warning_label: Label = $ContinueWarningLabel
@onready var texture_rect: TextureRect = $TextureRect
@onready var color_rect: ColorRect = $ColorRect
@onready var ready_button: Button = $ReadyButton
@onready var not_yet_button: Button = $NotYetButton

@onready var player = get_node_or_null("/root/Playground/Player")

var choice_text = "Are you ready to help the URL Bots find their way to their Views Rooms?"

func _ready() -> void:
	self.visible = false
	
	if not player:
		printerr("StartChoiceCh2Minigame1: Player node not found. Movement control might fail.")
		
	if ready_button:
		ready_button.connect("pressed", Callable(self, "_on_ready_button_pressed"))
	
	if not_yet_button:
		not_yet_button.connect("pressed", Callable(self, "_on_not_yet_button_pressed"))

func show_choice() -> void:
	if player and "can_move" in player:
		player.can_move = false
	
	self.visible = true
	grab_focus()
	
	rich_text_label.text = choice_text
	speaker_label.text = "GRIT"
	continue_warning_label.visible = false
	
	ready_button.visible = true
	not_yet_button.visible = true

func _on_ready_button_pressed() -> void:
	if player and "can_move" in player:
		player.can_move = true
	
	emit_signal("ready_selected")
	self.visible = false
	
	# Placeholder for scene transition
	var next_scene_path = "res://scenes/Levels/Chapter 2/chapter_2_world_part_4_1st_minigame_pt1.tscn"
	var error_code = get_tree().change_scene_to_file(next_scene_path)
	if error_code != OK:
		printerr("Error changing scene to: ", next_scene_path, " - Error code: ", error_code)

func _on_not_yet_button_pressed() -> void:
	if player and "can_move" in player:
		player.can_move = true
	
	emit_signal("not_ready_selected")
	self.visible = false
