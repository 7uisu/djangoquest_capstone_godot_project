#delivery_bot_2.tscn
extends CharacterBody2D

@export var speed: float = 100.0
@onready var animated_sprite = $AnimatedSprite2D

var can_move: bool = false
var trail_nodes: Array[Node] = [] 
var last_trail_position: Vector2
var trail_distance_threshold: float = 20.0 

func _ready():
	animated_sprite.play("idle_down")
	last_trail_position = global_position
	print("DeliveryBot2: _ready called. Initial can_move:", can_move)


func _physics_process(delta):
	# print("DeliveryBot2: _physics_process running. can_move:", can_move) # Keep this commented initially, too spammy
	if not can_move:
		return
	
	handle_movement()
	handle_trail()

func handle_movement():
	var input_vector = Vector2.ZERO
	
	# Only allow 4-directional movement (no diagonals)
	if Input.is_action_pressed("ui_right") and not Input.is_action_pressed("ui_left") and not Input.is_action_pressed("ui_up") and not Input.is_action_pressed("ui_down"):
		input_vector.x = 1
	elif Input.is_action_pressed("ui_left") and not Input.is_action_pressed("ui_right") and not Input.is_action_pressed("ui_up") and not Input.is_action_pressed("ui_down"):
		input_vector.x = -1
	elif Input.is_action_pressed("ui_up") and not Input.is_action_pressed("ui_down") and not Input.is_action_pressed("ui_left") and not Input.is_action_pressed("ui_right"):
		input_vector.y = -1
	elif Input.is_action_pressed("ui_down") and not Input.is_action_pressed("ui_up") and not Input.is_action_pressed("ui_left") and not Input.is_action_pressed("ui_right"):
		input_vector.y = 1
	
	velocity = input_vector * speed
	
	# Handle animations
	if velocity.length() > 0:
		# print("DeliveryBot2: Moving. Velocity:", velocity) # Debug movement
		if velocity.x > 0:
			animated_sprite.play("walking_right")
		elif velocity.x < 0:
			animated_sprite.play("walking_left")
		elif velocity.y < 0:
			animated_sprite.play("walking_up")
		elif velocity.y > 0:
			animated_sprite.play("walking_down")
	else:
		# Idle animations based on last direction
		# print("DeliveryBot2: Idle.") # Debug idle
		if animated_sprite.animation.begins_with("walking_right"):
			animated_sprite.play("idle_right")
		elif animated_sprite.animation.begins_with("walking_left"):
			animated_sprite.play("idle_left")
		elif animated_sprite.animation.begins_with("walking_up"):
			animated_sprite.play("idle_up")
		elif animated_sprite.animation.begins_with("walking_down"):
			animated_sprite.play("idle_down")
	
	move_and_slide()

func handle_trail():
	if global_position.distance_to(last_trail_position) >= trail_distance_threshold:
		var trail_node = create_trail_point(last_trail_position)
		trail_nodes.append(trail_node)
		last_trail_position = global_position

func create_trail_point(pos: Vector2) -> Node:
	var trail_point = ColorRect.new()
	trail_point.color = Color.YELLOW
	trail_point.size = Vector2(8, 8)
	trail_point.position = pos - Vector2(4, 4) 
	get_parent().add_child(trail_point) 
	return trail_point

func enable_movement():
	can_move = true
	print("DeliveryBot2: enable_movement() called. can_move is now:", can_move)

func disable_movement():
	can_move = false
	velocity = Vector2.ZERO
	if animated_sprite.animation.begins_with("walking"):
		var direction = animated_sprite.animation.split("_")[1]
		animated_sprite.play("idle_" + direction)
	print("DeliveryBot2: disable_movement() called. can_move is now:", can_move)

func reset_position_and_trail():
	for trail_node in trail_nodes:
		if is_instance_valid(trail_node):
			trail_node.queue_free()
	trail_nodes.clear()
	
	global_position = Vector2.ZERO 
	last_trail_position = global_position
	print("DeliveryBot2: reset_position_and_trail() called. Position reset.")
