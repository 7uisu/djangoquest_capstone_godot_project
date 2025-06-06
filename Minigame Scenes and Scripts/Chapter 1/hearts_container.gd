# Modified version of hearts_container.gd
extends HBoxContainer

@export var max_hearts: int = 3
var current_hearts: int = 3
var heart_scene = preload("res://scenes/UI/heart.tscn")

func _ready():
	# Make sure current hearts starts at maximum
	current_hearts = max_hearts
	
	# Now setup the hearts display
	setup_hearts()

func setup_hearts():
	# Clear any existing children
	for child in get_children():
		child.queue_free()
	
	print("[HEARTS] Setting up ", max_hearts, " hearts, current: ", current_hearts)
	
	# Create new hearts
	for i in range(max_hearts):
		var heart = heart_scene.instantiate()
		add_child(heart)
		# Ensure hearts start filled
		heart.set_heart_state(i < current_hearts)
		print("[HEARTS] Heart ", i, " state: ", i < current_hearts)

func update_hearts(amount: int):
	current_hearts = clampi(amount, 0, max_hearts)
	
	# Update heart visuals
	var i = 0
	for heart in get_children():
		if i < current_hearts:
			heart.set_heart_state(true)
		else:
			heart.set_heart_state(false)
		i += 1
