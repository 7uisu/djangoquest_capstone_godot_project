extends CharacterBody2D

const movement_speed = 100.0
var animated_sprite : AnimatedSprite2D
var animation_player : AnimationPlayer
var current_dir : String = "down"

# Declare character_data as an autoload.
@onready var character_data = get_node("/root/CharacterData")

func _ready():
	# Initialize onready variables inside _ready()
	animated_sprite = $AnimatedSprite2D

func _process(_delta):
	var direction : Vector2 = Vector2.ZERO
	direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	direction.y = Input.get_action_strength("down") - Input.get_action_strength("up")

	velocity = direction * movement_speed

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
		if current_dir == "":
			current_dir = "down"  # fallback default direction

func _physics_process(_delta):
	move_and_slide()
	# Animation control
	if velocity == Vector2.ZERO:
		if current_dir == "up":
			play_idle_animation("up")
		elif current_dir == "down":
			play_idle_animation("down")
		elif current_dir == "left":
			play_idle_animation("left")
		elif current_dir == "right":
			play_idle_animation("right")
		else:
			play_idle_animation("down")
	else:
		if current_dir == "up":
			play_walk_animation("up")
		elif current_dir == "down":
			play_walk_animation("down")
		elif current_dir == "left":
			play_walk_animation("left")
		elif current_dir == "right":
			play_walk_animation("right")

func play_idle_animation(direction):
	if character_data.selected_gender == "male":
		animated_sprite.play("male_idle_" + direction)
	else:
		animated_sprite.play("female_idle_" + direction)

func play_walk_animation(direction):
	if character_data.selected_gender == "male":
		animated_sprite.play("male_walking_" + direction)
	else:
		animated_sprite.play("female_walking_" + direction)
