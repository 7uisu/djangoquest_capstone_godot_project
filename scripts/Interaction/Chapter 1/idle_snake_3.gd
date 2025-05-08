extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	# Initialize the snake
	if animated_sprite:
		animated_sprite.play("default")
