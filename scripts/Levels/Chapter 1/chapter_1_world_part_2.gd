#chapter_1_world_part_2.gd
extends Node2D

# References to nodes
var player
var idle_snake

func _ready():
	# Store important node references
	player = $Player
	
	# Find the idle snake in the scene
	idle_snake = get_tree().get_nodes_in_group("idle_snake")[0]
	
	if not idle_snake:
		push_error("IdleSnake not found in the scene!")
		return
	
	# Focus camera on the IdleSnake after a brief delay
	await get_tree().create_timer(0.5).timeout
	focus_camera_on_snake()

func focus_camera_on_snake():
	# Tell the snake to take camera focus
	idle_snake.focus_camera()
	
	print("Camera transition initiated to focus on IdleSnake")
