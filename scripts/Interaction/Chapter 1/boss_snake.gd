#boss_snake.gd
extends CharacterBody2D

# === State Machine ===
enum State { ATTACK, REST, WINDUP }

# === Editable Timers from Inspector ===
@export var attack_duration: float = 10.0
@export var rest_duration: float = 15.0
@export var windup_duration: float = 5.0

# === Node References ===
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_timer = $StateTimer
@onready var small_projectile_timer = $SmallProjectileTimer
@onready var medium_projectile_timer = $MediumProjectileTimer
@onready var large_projectile_timer = $LargeProjectileTimer
@onready var marker = $marker2d

# === Projectile Scenes ===
var small_projectile_scene = preload("res://scenes/Levels/Chapter 1/projectile_small.tscn")
var medium_projectile_scene = preload("res://scenes/Levels/Chapter 1/projectile_medium.tscn")
var large_projectile_scene = preload("res://scenes/Levels/Chapter 1/projectile_large.tscn")

# === Variables ===
var current_state = State.WINDUP
var player: CharacterBody2D = null
var fixed_spawn_position = Vector2(4378.0, 32.0)  # Fixed spawn position

# === Ready ===
func _ready():
	print("[BOSS] BossSnake ready!")
	
	find_player()
	
	# Connect timers
	state_timer.timeout.connect(_on_state_timer_timeout)
	small_projectile_timer.timeout.connect(_on_small_projectile_timer_timeout)
	medium_projectile_timer.timeout.connect(_on_medium_projectile_timer_timeout)
	large_projectile_timer.timeout.connect(_on_large_projectile_timer_timeout)

	change_state(State.WINDUP)

# === Process ===
func _process(_delta):
	if not player or not is_instance_valid(player):
		find_player()
		return

# === Player Finder ===
func find_player():
	# Try direct path
	player = get_node_or_null("../Player")
	if player:
		print("[BOSS] Player found via direct path")
		return
	
	# Tree search
	var root = get_tree().get_root()
	if root:
		var nodes = root.find_children("*", "CharacterBody2D", true, false)
		for node in nodes:
			if node.has_method("is_player") or "Player" in node.name:
				player = node
				print("[BOSS] Player found via tree search: ", player.name)
				return
	
	print("[BOSS] Player not found.")

# === State Control ===
func change_state(new_state):
	current_state = new_state
	print("[BOSS] State changed to: ", State.keys()[new_state])

	# Stop projectile timers first
	small_projectile_timer.stop()
	medium_projectile_timer.stop()
	large_projectile_timer.stop()

	match new_state:
		State.ATTACK:
			play_animation("attack")
			state_timer.start(attack_duration)
			small_projectile_timer.start(0.7)
			medium_projectile_timer.start(1.5)
			large_projectile_timer.start(3.0)
		State.REST:
			play_animation("rest")
			state_timer.start(rest_duration)
		State.WINDUP:
			play_animation("windup")
			state_timer.start(windup_duration)

func play_animation(name: String):
	if animated_sprite and animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation(name):
		animated_sprite.play(name)
		print("[BOSS] Playing animation: ", name)
	else:
		print("[BOSS] Animation not found: ", name)

# === Timer Callbacks ===
func _on_state_timer_timeout():
	match current_state:
		State.ATTACK:
			change_state(State.REST)
		State.REST:
			change_state(State.WINDUP)
		State.WINDUP:
			change_state(State.ATTACK)

func _on_small_projectile_timer_timeout():
	if current_state == State.ATTACK:
		print("[BOSS] Small projectile fired")
		shoot_projectile(small_projectile_scene)

func _on_medium_projectile_timer_timeout():
	if current_state == State.ATTACK:
		print("[BOSS] Medium projectile fired")
		shoot_projectile(medium_projectile_scene)

func _on_large_projectile_timer_timeout():
	if current_state == State.ATTACK:
		print("[BOSS] Large projectile fired")
		shoot_projectile(large_projectile_scene)

# === Shoot Projectiles ===
func shoot_projectile(projectile_scene: PackedScene):
	if not player:
		print("[BOSS] Cannot shoot - player missing")
		return
	
	# Create the projectile instance
	var projectile = projectile_scene.instantiate()
	if not projectile:
		print("[BOSS] Error instantiating projectile!")
		return
	
	# IMPORTANT: Add projectile to scene TREE ROOT, not current scene
	# This is crucial to prevent parent relationship issues
	get_tree().root.add_child(projectile)
	
	# Use fixed spawn position
	var spawn_position = fixed_spawn_position
	
	# Calculate direction with randomness
	var direction = (player.global_position - spawn_position).normalized()
	direction = direction.rotated(randf_range(-0.2, 0.2))
	
	print("[BOSS] Projectile spawn position: ", spawn_position)
	print("[BOSS] Player position: ", player.global_position)
	
	# Setup the projectile
	if projectile.has_method("setup"):
		# First make sure it's at the right position
		projectile.global_position = spawn_position
		projectile.setup(spawn_position, direction)
		print("[BOSS] Projectile setup complete with direction ", direction)
	else:
		print("[BOSS] Warning: Projectile missing setup method!")
		projectile.global_position = spawn_position
		if "direction" in projectile:
			projectile.direction = direction
