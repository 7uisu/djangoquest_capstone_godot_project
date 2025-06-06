#projectile_base.gd
extends Area2D

@export var speed: float = 200.0
@export var damage: int = 1
@export var rotation_speed: float = 5.0
@export var lifetime: float = 15.0

# Level bounds (matching your camera limits)
var limit_left := 4144
var limit_right := 4752
var limit_top := -176
var limit_bottom := 368

var direction: Vector2 = Vector2.ZERO
var initialized: bool = false
var creation_time: float = 0.0

func _ready():
	creation_time = Time.get_ticks_msec() / 1000.0
	
	# Connect signals
	body_entered.connect(_on_body_entered)
	
	# Set up collision to match your game's setup
	set_collision_layer_value(2, true)  # Layer 2 for projectile
	set_collision_mask_value(1, true)   # Detect player on layer 1
	
	# CRITICAL: Disable collision detection initially
	monitoring = false
	monitorable = false
	
	# Set up lifetime timer
	var timer = get_tree().create_timer(lifetime)
	timer.timeout.connect(func(): queue_free())
	
	print("[PROJECTILE] Created at global position: ", global_position)

func _process(delta):
	# Skip the first frame to allow proper initialization
	if not initialized:
		initialized = true
		return
	
	# Move in the set direction
	position += direction * speed * delta
	
	# Rotate for spinning effect
	rotation += rotation_speed * delta
	
	# Enable collision after a short delay
	if not monitoring and (Time.get_ticks_msec() / 1000.0) - creation_time > 0.5:
		monitoring = true
		monitorable = true
		print("[PROJECTILE] Collision enabled at: ", global_position)
	
	# Debug position occasionally
	if Engine.get_frames_drawn() % 60 == 0:
		print("[PROJECTILE] Current position: ", global_position)
	
	# IMPORTANT: Don't check for out of bounds for the first 1 second
	# This prevents premature despawning
	if (Time.get_ticks_msec() / 1000.0) - creation_time < 1.0:
		return
	
	# Check if outside the level bounds (using camera limits)
	if (global_position.x < limit_left - 50 || 
		global_position.x > limit_right + 50 || 
		global_position.y < limit_top - 50 || 
		global_position.y > limit_bottom + 50):
		print("[PROJECTILE] Despawning - out of level bounds at: ", global_position)
		queue_free()

func _on_body_entered(body):
	print("[PROJECTILE] Collision with: ", body.name)
	
	# Don't collide with the boss
	if "Boss" in body.name or "Snake" in body.name:
		print("[PROJECTILE] Ignoring collision with boss")
		return
	
	# Handle player collision
	if body.has_method("is_player") or "Player" in body.name:
		print("[PROJECTILE] Hit player!")
		
		# Get the minigame manager (direct path for this specific scene)
		var minigame_manager = get_node_or_null("/root/chapter_1_world_part_3_2nd_minigame/MinigameManager")
		
		# If not found, try getting the current scene first
		if not minigame_manager:
			var current_scene = get_tree().current_scene
			if current_scene:
				minigame_manager = current_scene.get_node_or_null("MinigameManager")
		
		# Apply damage through the manager
		if minigame_manager and minigame_manager.has_method("take_damage"):
			print("[PROJECTILE] Applying damage via minigame manager")
			minigame_manager.take_damage(damage)
		else:
			print("[PROJECTILE] WARNING: Could not find MinigameManager! Trying to find HeartsContainer directly...")
			
			# Fallback - try to find the HeartsContainer directly
			var hearts_container = get_node_or_null("/root/chapter_1_world_part_3_2nd_minigame/MinigameManager/UILayer/HeartsContainer")
			if hearts_container and hearts_container.has_method("update_hearts"):
				print("[PROJECTILE] Found HeartsContainer, applying damage directly")
				hearts_container.current_hearts -= damage
				hearts_container.update_hearts(hearts_container.current_hearts)
				
				# Also check if we need to show the respawn UI
				if hearts_container.current_hearts <= 0:
					var respawn_ui = get_node_or_null("/root/chapter_1_world_part_3_2nd_minigame/MinigameManager/UILayer/RespawnUIWorld1Minigame2")
					if respawn_ui:
						respawn_ui.visible = true
						print("[PROJECTILE] Showing respawn UI due to zero health")
			else:
				print("[PROJECTILE] FATAL: Could not find any way to apply damage!")
		
		# Remove self after hitting player
		queue_free()

func setup(pos: Vector2, dir: Vector2):
	# IMPORTANT: Must set global position, not just position
	global_position = pos
	direction = dir.normalized()
	
	# Force position update to take effect immediately
	force_update_transform()
	
	# Get level bounds from scene if available
	var level = get_tree().current_scene
	if level and level.has_method("get") and level.get("limit_left") != null:
		limit_left = level.limit_left
		limit_right = level.limit_right
		limit_top = level.limit_top
		limit_bottom = level.limit_bottom
		print("[PROJECTILE] Using level bounds: ", limit_left, ", ", limit_right, ", ", limit_top, ", ", limit_bottom)
	
	print("[PROJECTILE] Setup complete at: ", global_position)
	print("[PROJECTILE] Direction: ", direction)
