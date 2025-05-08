#idle_snake2.gd
extends CharacterBody2D

# References to components
@onready var animated_sprite = $AnimatedSprite2D
@onready var camera = $Camera2D

func _ready():
	# Initialize the snake
	if animated_sprite:
		animated_sprite.play("default")
	
	# Make sure camera starts inactive
	if camera:
		camera.enabled = false
		camera.add_to_group("cameras")
	
	print("[IDLESNAKE2] Initialized at position:", position)

# Function to make snake camera the active camera
func focus_camera():
	if camera:
		# Make sure all other cameras are disabled first
		for other_camera in get_tree().get_nodes_in_group("cameras"):
			if other_camera != camera:
				other_camera.enabled = false
		
		# Now enable this camera
		camera.enabled = true
		print("[IDLESNAKE2] Camera focused")
	else:
		push_error("Camera2D not found on IdleSnake2")

# Play idle animation
func play_idle_animation():
	if animated_sprite:
		animated_sprite.play("default")

# Play walking animation if available
func play_walking_animation():
	if animated_sprite:
		if animated_sprite.sprite_frames.has_animation("walking"):
			animated_sprite.play("walking")
		else:
			animated_sprite.play("default")
