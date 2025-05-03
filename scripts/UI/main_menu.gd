extends Node

@onready var quit_dialog: ConfirmationDialog = $QuitConfirmationDialog

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Cutscenes/introduction_cutscene.tscn")

func _on_quit_button_pressed() -> void:
	quit_dialog.popup_centered()  # Show the confirmation dialog

func _on_quit_confirmation_dialog_confirmed() -> void:
	get_tree().quit()

func _on_quit_confirmation_dialog_canceled() -> void:
	quit_dialog.hide()  # Optional, it's hidden by default
