# scripts/Autoload or Global/character_data.gd
extends Node

var selected_gender: String = ""  # "male" or "female"
var player_name: String = ""

# Unlocked levels status
var unlocked_level_1: bool = true # Usually true from the start or after intro
var unlocked_level_2: bool = false
var unlocked_level_3: bool = false
var unlocked_level_4: bool = false

func reset_data():
	selected_gender = ""
	player_name = ""
	unlocked_level_1 = true # Or false if intro needs to be completed first
	unlocked_level_2 = false
	unlocked_level_3 = false
	unlocked_level_4 = false
	print("CharacterData: Data reset.")

func set_all_data(name: String, gender: String, ul1: bool, ul2: bool, ul3: bool, ul4: bool):
	player_name = name
	selected_gender = gender
	unlocked_level_1 = ul1
	unlocked_level_2 = ul2
	unlocked_level_3 = ul3
	unlocked_level_4 = ul4
	print("CharacterData: All data set (e.g., from loaded save).")
