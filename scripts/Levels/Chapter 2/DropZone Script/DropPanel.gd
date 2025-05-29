# ============================================
# UPDATED DROP PANEL CLASS
# DropPanel.gd - Modified to work with auto-check
# ============================================

# DropPanel.gd
extends Panel
class_name DropPanel

@export var zone_id: String = ""
var current_data: String = ""
var is_filled: bool = false

@onready var label = $Label

signal item_dropped(zone_id: String, data: String)

func _ready():
	# Create label if it doesn't exist
	if not has_node("Label"):
		label = Label.new()
		label.name = "Label"
		add_child(label)
		label.text = "Drop here"
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.anchors_preset = Control.PRESET_FULL_RECT

func set_label_text(text: String):
	if label:
		label.text = text

func reset_zone():
	is_filled = false
	current_data = ""
	if is_inside_tree():
		modulate = Color.WHITE
	if label:
		label.text = "Drop here"

func _can_drop_data(pos, data):
	# Always allow dropping (will replace existing content)
	if is_inside_tree():
		modulate = Color.GREEN
	return true

func _drop_data(pos, data):
	current_data = data
	is_filled = true
	
	if label:
		label.text = data
	
	if is_inside_tree():
		modulate = Color.WHITE
	
	item_dropped.emit(zone_id, data)

func _on_mouse_exited():
	if is_inside_tree():
		modulate = Color.WHITE
