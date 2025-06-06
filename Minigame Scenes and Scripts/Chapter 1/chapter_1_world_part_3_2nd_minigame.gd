extends Node2D

@onready var player = $Player
@export var limit_left := 4144
@export var limit_right := 4752
@export var limit_top := -176
@export var limit_bottom := 368

func _ready():
	var camera = player.get_node_or_null("Camera2D")
	if camera:
		camera.limit_left = limit_left
		camera.limit_right = limit_right
		camera.limit_top = limit_top
		camera.limit_bottom = limit_bottom
		camera.enabled = true
		camera.make_current()  # This replaces camera.current = true
