# ============================================
# DRAG BUTTON CLASS - WITH NULL CHECKS
# Create this as DragButton.gd script
# ============================================

# DragButton.gd
extends Button
class_name DragButtonFixed

@export var drag_data: String = ""
var original_position: Vector2
var is_dragging: bool = false

signal drag_started(data: String)
signal drag_ended()

func _ready():
	original_position = position

func setup(data: String):
	drag_data = data
	text = data
	
	# Visual styling based on data type - with null check
	if is_inside_tree():
		if data.begins_with("#"):
			modulate = Color.html(data)
		else:
			modulate = Color.WHITE

func _get_drag_data(pos):
	is_dragging = true
	drag_started.emit(drag_data)
	
	var preview = Label.new()
	preview.text = text
	preview.add_theme_color_override("font_color", Color.WHITE)
	set_drag_preview(preview)
	
	return drag_data

func _notification(what):
	match what:
		NOTIFICATION_DRAG_END:
			is_dragging = false
			drag_ended.emit()
