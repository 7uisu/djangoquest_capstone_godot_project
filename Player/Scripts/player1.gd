extends CharacterBody2D

const SPEED = 100.0 # Corrected variable name
var animated_sprite : AnimatedSprite2D
var animation_player : AnimationPlayer
var current_dir : String = "down"

func _ready():
	# Initialize onready variables inside _ready()
	animated_sprite = $AnimatedSprite2D

func _process(_delta):
	var direction : Vector2 = Vector2.ZERO
	direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	direction.y = Input.get_action_strength("down") - Input.get_action_strength("up")

	velocity = direction * SPEED # Corrected variable name

	# Determine current direction for animation
	if direction.x > 0 and direction.y == 0:
		current_dir = "right"
	elif direction.x < 0 and direction.y == 0:
		current_dir = "left"
	elif direction.y > 0 and direction.x == 0:
		current_dir = "down"
	elif direction.y < 0 and direction.x == 0:
		current_dir = "up"
	elif direction.x == 0 and direction.y == 0:
		pass #keep the last direction

	pass

func _physics_process(_delta):
	move_and_slide()

	# Animation control
	if velocity == Vector2.ZERO:
		if current_dir == "up":
			animated_sprite.play("Idle_up")
		elif current_dir == "down":
			animated_sprite.play("Idle_down")
		elif current_dir == "left":
			animated_sprite.play("Idle_left")
		elif current_dir == "right":
			animated_sprite.play("Idle_right")
		else:
			animated_sprite.play("Idle_down")  # Default
	else:
		if current_dir == "up":
			animated_sprite.play("walk_up")
		elif current_dir == "down":
			animated_sprite.play("walk_down")
		elif current_dir == "left":
			animated_sprite.play("walk_left")
		elif current_dir == "right":
			animated_sprite.play("walk_right")
