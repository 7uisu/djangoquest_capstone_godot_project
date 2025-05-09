extends Node2D

# References to nodes
@onready var django_rocket = $DjangoRocket
@onready var rocket_fire = $DjangoRocket/Fire2
@onready var ui_layer = $UILayer
@onready var interaction_dialogue = $UILayer/InteractionDialogue6

# Animation properties
var rocket_start_pos = Vector2(240.0, 137.0)
var rocket_end_pos = Vector2(240.0, -223.0)
var rocket_speed = 150.0  # Adjust speed as needed
var rocket_flying = false
var is_dialogue_shown = false

func _ready():
	# Ensure the rocket is at the starting position
	django_rocket.position = rocket_start_pos
	
	# Start the fire animation immediately
	if rocket_fire:
		rocket_fire.visible = true
		rocket_fire.play("default")
	
	# Make sure the dialogue is hidden at the start
	if interaction_dialogue:
		interaction_dialogue.visible = false
		# Connect to the dialogue finished signal
		interaction_dialogue.connect("dialogue_finished", _on_dialogue_finished)
	
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
			
			# Keep the fire animation playing while the dialogue is shown
			# (Alternatively, you could stop it here if you want the fire to stop when the rocket stops)
			# if rocket_fire:
			#     rocket_fire.stop()
			
			# Once the rocket has reached its destination, show the dialogue
			show_dialogue()

func show_dialogue():
	if interaction_dialogue and not is_dialogue_shown:
		is_dialogue_shown = true
		# Make dialogue visible and start it
		interaction_dialogue.visible = true
		# Start dialogue with the rocket launch dialogue key
		interaction_dialogue.start_dialogue("rocket_launch")

func _on_dialogue_finished():
	# When dialogue is finished, change to the next scene
	get_tree().change_scene_to_file("res://scenes/Cutscenes/rocket_travelling_cutscene_1.tscn")
