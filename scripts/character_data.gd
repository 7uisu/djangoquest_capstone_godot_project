extends Node

var selected_gender: String = ""  # "" (empty string) or null are good defaults
var player_name: String = ""  # Add the player_name property

func reset_data():
	selected_gender = ""
	player_name = ""  # Reset player_name too if needed
