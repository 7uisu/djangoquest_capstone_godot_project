extends Node2D

# References to nodes
@onready var django_rocket = $DjangoRocket
@onready var rocket_fire = $DjangoRocket/Fire2

# Animation properties
var rocket_start_pos = Vector2(240.0, 137.0)
var rocket_end_pos = Vector2(240.0, -223.0)
var rocket_speed = 150.0  # Adjust speed as needed
var rocket_flying = false
# var is_dialogue_shown = false # This variable is not used, can be removed if not needed

func _ready():
	# Ensure the rocket is at the starting position
	django_rocket.position = rocket_start_pos
	
	# Start the fire animation immediately
	if rocket_fire:
		rocket_fire.visible = true
		rocket_fire.play("default")
	
	# Start the rocket flying animation after a short delay
	await get_tree().create_timer(1.0).timeout
	rocket_flying = true

func _process(delta):
	if rocket_flying:
		# Move the rocket upwards
		var direction = (rocket_end_pos - django_rocket.position).normalized()
		django_rocket.position += direction * rocket_speed * delta
		
		# Check if the rocket has reached its destination
		if django_rocket.position.distance_to(rocket_end_pos) < 5.0:
			rocket_flying = false
			
			# Keep the fire animation playing if needed, or stop it.
			# For example, to stop the fire:
			# if rocket_fire:
			#     rocket_fire.stop()
			#     rocket_fire.visible = false

			# Change scene AFTER the rocket has reached its destination
			get_tree().change_scene_to_file("res://scenes/Hub Area/hub_area.tscn")

	# Removed get_tree().change_scene_to_file from here
