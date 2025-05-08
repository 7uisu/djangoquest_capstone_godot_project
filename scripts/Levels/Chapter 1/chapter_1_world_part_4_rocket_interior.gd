extends Node2D

# This script manages the rocket interior scene

func _ready():
	print("Rocket interior scene loaded")
	
	# Setup the dashboard interactive object
	var dashboard = get_node_or_null("World1Minigame2Dashboard")
	if dashboard:
		print("Dashboard object found and initialized")
