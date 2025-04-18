extends Node


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/visual_novel_ui.tscn")
