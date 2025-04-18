extends CharacterBody2D

# Constants for movement
const movement_speed = 120.0  # Speed of the character's movement

# Node variables
var animated_sprite : AnimatedSprite2D # Declare a variable to hold the AnimatedSprite2D node.
var animation_player : AnimationPlayer # Declare a variable to hold the AnimationPlayer node.
var current_dir : String = "down" # Stores the current direction the character is facing.  Defaults to "down".

# Declare character_data as an autoload.  This assumes you have a singleton autoload named "CharacterData".
@onready var character_data = get_node("/root/CharacterData")

func _ready():
	# Called when the node enters the scene tree.  Good place for initialization.

	# Get references to child nodes.  Using @onready ensures they are available when the scene is ready.
	animated_sprite = $AnimatedSprite2D # Gets the AnimatedSprite2D node.  Assumes it's a direct child.
	#animation_player = $AnimationPlayer # Gets the AnimationPlayer node.

func _process(_delta):
	# Called every frame.  Handles input and updates character velocity.
	var direction : Vector2 = Vector2.ZERO # Initialize a zero vector for movement direction.

	# Get input for horizontal movement.
	direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	# Get input for vertical movement.
	direction.y = Input.get_action_strength("down") - Input.get_action_strength("up")

	velocity = direction * movement_speed # basic velocity

	# Check if there is any input.
	if direction != Vector2.ZERO:
		direction = direction.normalized() # Normalize the direction vector to have a length of 1, preventing faster diagonal movement.
		velocity = direction * movement_speed # Apply speed to the normalized direction.

		# Determine current direction for animation.  This logic determines the cardinal or diagonal direction based on input.
		if direction.x > 0 and direction.y < 0:
			current_dir = "up_right"
		elif direction.x < 0 and direction.y < 0:
			current_dir = "up_left"
		elif direction.x > 0 and direction.y > 0:
			current_dir = "down_right"
		elif direction.x < 0 and direction.y > 0:
			current_dir = "down_left"
		elif direction.x > 0:
			current_dir = "right"
		elif direction.x < 0:
			current_dir = "left"
		elif direction.y > 0:
			current_dir = "down"
		elif direction.y < 0:
			current_dir = "up"
	else:
		velocity = Vector2.ZERO # If no input, set velocity to zero.

func _physics_process(_delta):
	# Called at a fixed rate, typically 60 times per second.  Handles physics and movement.
	move_and_slide() # Built-in Godot function to move the character and handle collisions.
	# Animation control
	if velocity == Vector2.ZERO:
		play_idle_animation(current_dir)
	else:
		play_walk_animation(current_dir)

func play_idle_animation(direction):
	# Function to play the idle animation based on the current direction.
	if character_data.selected_gender == "male":
		animated_sprite.play("male_idle_" + direction) # Plays the male idle animation.  Assumes animation names follow this convention.
	else:
		animated_sprite.play("female_idle_" + direction) # Plays the female idle animation.

func play_walk_animation(direction):
	# Function to play the walking animation based on the current direction.
	if character_data.selected_gender == "male":
		animated_sprite.play("male_walking_" + direction) # Plays the male walking animation.
	else:
		animated_sprite.play("female_walking_" + direction) # Plays the female walking animation.
