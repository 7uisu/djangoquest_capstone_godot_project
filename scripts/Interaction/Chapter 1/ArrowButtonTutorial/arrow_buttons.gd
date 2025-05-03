extends Node2D

@onready var up_arrow = $UpArrow
@onready var down_arrow = $DownArrow
@onready var left_arrow = $LeftArrow
@onready var right_arrow = $RightArrow
@onready var move_label = $MoveLabel  # Assuming your Label node is named MoveLabel

var has_moved = false

func _ready():
	# Play default animation
	up_arrow.play("default")
	down_arrow.play("default")
	left_arrow.play("default")
	right_arrow.play("default")

func _process(_delta):
	if not has_moved and (
		Input.is_action_pressed("up") or
		Input.is_action_pressed("down") or
		Input.is_action_pressed("left") or
		Input.is_action_pressed("right")
	):
		has_moved = true
		hide()  # Hides the entire ArrowButtons node, including the arrows and label
