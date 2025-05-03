extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var show_once: bool = false

var has_interacted: bool = false
var player_is_inside: bool = false

# Idle state variable to track which idle animation to play
var current_idle_animation: String = "pip_idle_left_1"  # Default to the first idle animation

func _ready():
	# Start the default idle animation
	animated_sprite.play(current_idle_animation)
	# Set initial rotation based on the idle animation

# Function to cycle through idle animations
func change_idle_animation():
	# Weighted list: "pip_idle_left_3" appears more often
	var animations = [
		"pip_idle_left_3", "pip_idle_left_3", "pip_idle_left_3",  # Higher weight
		"pip_idle_left_1", 
		"pip_idle_left_2"
	]
	
	# Randomly select an animation with weighted probability
	var next_animation = animations[randi() % animations.size()]
	
	animated_sprite.play(next_animation)
	current_idle_animation = next_animation
