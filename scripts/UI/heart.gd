#heart.gd
extends Control

@onready var filled_heart = $FilledHeart
@onready var empty_heart = $EmptyHeart

func set_heart_state(is_filled: bool):
	filled_heart.visible = is_filled
	empty_heart.visible = !is_filled
