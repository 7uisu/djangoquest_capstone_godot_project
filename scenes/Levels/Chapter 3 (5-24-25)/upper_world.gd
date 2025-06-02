extends Node2D

func _ready():
	if NavigationManager.spawn_door_tag != null:
		_on_level_spawn(NavigationManager.spawn_door_tag)
		
func _on_level_spawn(destiantion_tag: String):
	var door_path = "Doors/Door_" + destiantion_tag
	var door = get_node(door_path) as Door
	NavigationManager.trigger_player_spawn(door.spawn.global_position, door.spawn_direction)
