#upper_world.gd
extends Node2D

func _ready():
	print("spawn_door_tag: ", NavigationManager.spawn_door_tag)
	if NavigationManager.spawn_door_tag != null and NavigationManager.spawn_door_tag != "":
		# Coming from another level - spawn at door
		print("Spawning at door: ", NavigationManager.spawn_door_tag)
		on_level_spawn(NavigationManager.spawn_door_tag)
	else:
		# Playing scene directly - spawn at default position
		print("Spawning at default position")
		NavigationManager.trigger_player_spawn(Vector2(329, 134), "down")
		
func on_level_spawn(destination_tag: String):
	var door_path = "Doors/Door_" + destination_tag
	var door = get_node(door_path) as Door
	NavigationManager.trigger_player_spawn(door.spawn.global_position, door.spawn_direction)
