#navigation_manager.gd
extends Node

const scene_upper = preload("res://scenes/Levels/Chapter 3 (5-24-25)/Story Flow World 3/chapter_3_world_part_1.tscn")
const scene_mines = preload("res://scenes/Levels/Chapter 3 (5-24-25)/Story Flow World 3/chapter_3_world_part_2.tscn")

signal on_trigger_player_spawn

var spawn_door_tag

func go_to_level(level_tag, destination_tag):
	var scene_to_load
	
	match level_tag:
		"Upper":
			scene_to_load = scene_upper
		"Mines":
			scene_to_load = scene_mines
			
	if scene_to_load != null:
		spawn_door_tag = destination_tag
		get_tree().change_scene_to_packed(scene_to_load)
		
func trigger_player_spawn(position: Vector2, direction: String):
	on_trigger_player_spawn.emit(position, direction)
