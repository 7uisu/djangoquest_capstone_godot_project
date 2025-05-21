extends Node2D

# Main script for Chapter 2 World Part 4

@onready var player = $Player
@onready var y_sort_layer = $YSortLayer
@onready var ui_layer = $UILayer

# References to the interactable objects
@onready var delivery_bot_1 = $YSortLayer/DeliveryBot1Interactable
@onready var delivery_bot_2 = $YSortLayer/DeliveryBot2Interactable
@onready var delivery_bot_3 = $YSortLayer/DeliveryBot3Interactable
@onready var microwave = $YSortLayer/MicrowaveInteractable
@onready var pip_cat = $PipCatInteractable
@onready var bulletin_board = $BulletinBoard

# References to the UI elements
@onready var red_bot_dialogue = $UILayer/RedBotInteractionDialogue
@onready var yellow_bot_dialogue = $UILayer/YellowBotInteractionDialogue
@onready var blue_bot_dialogue = $UILayer/BlueBotInteractionDialogue
@onready var microwave_dialogue = $UILayer/MicrowaveInteractionDialogue
@onready var pip_cat_dialogue = $UILayer/PipCatInteractionDialogue
@onready var bulletin_board_ui = $UILayer/BulletinBoardUI
@onready var minigame_choice_ui = $UILayer/StartChoiceCh2Minigame1

func _ready() -> void:
	# Connect signals for interactable objects
	if delivery_bot_1:
		delivery_bot_1.connect("body_entered", Callable(delivery_bot_1, "_on_body_entered"))
		delivery_bot_1.connect("body_exited", Callable(delivery_bot_1, "_on_body_exited"))
		
	if delivery_bot_2:
		delivery_bot_2.connect("body_entered", Callable(delivery_bot_2, "_on_body_entered"))
		delivery_bot_2.connect("body_exited", Callable(delivery_bot_2, "_on_body_exited"))
		
	if delivery_bot_3:
		delivery_bot_3.connect("body_entered", Callable(delivery_bot_3, "_on_body_entered"))
		delivery_bot_3.connect("body_exited", Callable(delivery_bot_3, "_on_body_exited"))
		
	if microwave:
		microwave.connect("body_entered", Callable(microwave, "_on_body_entered"))
		microwave.connect("body_exited", Callable(microwave, "_on_body_exited"))
		
	if pip_cat:
		pip_cat.connect("body_entered", Callable(pip_cat, "_on_body_entered"))
		pip_cat.connect("body_exited", Callable(pip_cat, "_on_body_exited"))
		
	if bulletin_board:
		bulletin_board.connect("body_entered", Callable(bulletin_board, "_on_body_entered"))
		bulletin_board.connect("body_exited", Callable(bulletin_board, "_on_body_exited"))
	
	# Connect signals for minigame choice UI
	if minigame_choice_ui:
		minigame_choice_ui.connect("ready_selected", Callable(self, "_on_minigame_ready_selected"))
		minigame_choice_ui.connect("not_ready_selected", Callable(self, "_on_minigame_not_ready_selected"))

func _on_minigame_ready_selected() -> void:
	# This will be handled by the StartChoiceCh2Minigame1 script itself
	# It will change to the minigame scene
	pass

func _on_minigame_not_ready_selected() -> void:
	# Player chose not to start the minigame yet
	# Just close the dialogue and let them continue exploring
	pass
