# chapter_2_world_2nd_minigame_pt1.gd
# Fixed Node2D drawing system

extends Node2D

# --- Node References ---
@onready var ui_layer = $UILayer
@onready var instruction_label = $UILayer/InstructionLabel
@onready var feedback_label = $UILayer/FeedbackLabel
@onready var robot_template_button = $UILayer/RobotTemplateButton
@onready var robot_static_button = $UILayer/RobotStaticButton
@onready var settings_py_button = $UILayer/SettingsPyButton
@onready var feedback_timer = $UILayer/FeedbackTimer

# --- State Variables ---
var template_connected: bool = false
var static_connected: bool = false

# --- Drag State ---
var is_dragging: bool = false
var drag_button: Control = null
var drag_type: String = ""
var drag_start_pos: Vector2 = Vector2.ZERO

# --- Connection Lines ---
var template_line_start: Vector2 = Vector2.ZERO
var template_line_end: Vector2 = Vector2.ZERO
var static_line_start: Vector2 = Vector2.ZERO
var static_line_end: Vector2 = Vector2.ZERO

# --- Colors ---
var DRAG_COLOR = Color.YELLOW
var HOVER_COLOR = Color.LIME
var CONNECTED_COLOR = Color.GREEN
var LINE_WIDTH = 6

func _ready():
	# Connect signals
	feedback_timer.timeout.connect(_on_feedback_timer_timeout)
	
	# Connect button signals for custom drag handling
	robot_template_button.button_down.connect(_on_template_button_down)
	robot_static_button.button_down.connect(_on_static_button_down)
	
	# Put UI layer above the drawing
	ui_layer.layer = 1
	
	# Force initial draw
	call_deferred("queue_redraw")
	
	print("Node2D drag system initialized")

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed and is_dragging:
			# Mouse released - check for drop
			_handle_drop()
			_stop_dragging()
	
	elif event is InputEventMouseMotion and is_dragging:
		# Mouse moved while dragging - trigger redraw
		queue_redraw()

func _draw():
	print("=== DRAW CALLED ===")
	print("Canvas transform: ", get_canvas_transform())
	print("Global transform: ", global_transform)
	print("Dragging: ", is_dragging)
	print("Template connected: ", template_connected)
	print("Static connected: ", static_connected)
	
	# Convert UI coordinates to Node2D space
	var canvas_transform = get_canvas_transform()
	
	# Draw permanent connection lines
	if template_connected:
		var start = canvas_transform * template_line_start
		var end = canvas_transform * template_line_end
		_draw_line_with_circles(start, end, CONNECTED_COLOR)
		print("Drawing template connection: ", start, " to ", end)
	
	if static_connected:
		var start = canvas_transform * static_line_start
		var end = canvas_transform * static_line_end
		_draw_line_with_circles(start, end, CONNECTED_COLOR)
		print("Drawing static connection: ", start, " to ", end)
	
	# Draw drag line
	if is_dragging:
		_draw_drag_line()
		print("Drawing drag line")
	
	# Draw debug info
	_draw_debug_info()

func _draw_line_with_circles(start_pos: Vector2, end_pos: Vector2, color: Color):
	# Make lines more visible
	draw_line(start_pos, end_pos, color, LINE_WIDTH)
	draw_line(start_pos, end_pos, Color.WHITE, LINE_WIDTH - 2)  # Inner white line
	draw_circle(start_pos, 12, color)
	draw_circle(start_pos, 8, Color.WHITE)
	draw_circle(end_pos, 12, color)
	draw_circle(end_pos, 8, Color.WHITE)

func _draw_drag_line():
	var mouse_pos = get_global_mouse_position()
	var canvas_transform = get_canvas_transform()
	
	# Convert to Node2D space
	var start_in_node2d = canvas_transform * drag_start_pos
	var mouse_in_node2d = canvas_transform * mouse_pos
	
	# Check if hovering over target
	var is_hovering = _is_mouse_over_settings(mouse_pos)
	var color = HOVER_COLOR if is_hovering else DRAG_COLOR
	
	# Highlight target when hovering
	if is_hovering:
		var target_pos = canvas_transform * settings_py_button.global_position
		var target_size = settings_py_button.size
		var target_rect = Rect2(target_pos, target_size)
		draw_rect(target_rect, HOVER_COLOR, false, 4)
		# Add glow effect
		for i in range(3):
			draw_rect(target_rect.grow(4 + i * 2), Color(HOVER_COLOR.r, HOVER_COLOR.g, HOVER_COLOR.b, 0.3 - i * 0.1), false, 2)
	
	# Draw the drag line with enhanced visibility
	draw_line(start_in_node2d, mouse_in_node2d, color, LINE_WIDTH)
	draw_line(start_in_node2d, mouse_in_node2d, Color.WHITE, LINE_WIDTH - 2)
	draw_circle(start_in_node2d, 12, color)
	draw_circle(start_in_node2d, 8, Color.WHITE)
	draw_circle(mouse_in_node2d, 8, color)
	draw_circle(mouse_in_node2d, 4, Color.WHITE)

func _draw_debug_info():
	# Draw coordinate system debug info
	var canvas_transform = get_canvas_transform()
	
	# Draw origin
	draw_circle(Vector2.ZERO, 5, Color.RED)
	
	# Draw button positions in Node2D space
	if robot_template_button:
		var pos = canvas_transform * (robot_template_button.global_position + robot_template_button.size / 2)
		draw_circle(pos, 3, Color.BLUE)
		# Skip text for now to avoid font issues
	
	if robot_static_button:
		var pos = canvas_transform * (robot_static_button.global_position + robot_static_button.size / 2)
		draw_circle(pos, 3, Color.CYAN)
		# Skip text for now to avoid font issues
	
	if settings_py_button:
		var pos = canvas_transform * (settings_py_button.global_position + settings_py_button.size / 2)
		draw_circle(pos, 3, Color.MAGENTA)
		# Skip text for now to avoid font issues

func _is_mouse_over_settings(mouse_pos: Vector2) -> bool:
	var rect = Rect2(settings_py_button.global_position, settings_py_button.size)
	return rect.has_point(mouse_pos)

# --- Button Handlers ---
func _on_template_button_down():
	if template_connected:
		return
	
	_start_dragging(robot_template_button, "template")

func _on_static_button_down():
	if static_connected:
		return
	
	_start_dragging(robot_static_button, "static")

func _start_dragging(button: Control, type: String):
	is_dragging = true
	drag_button = button
	drag_type = type
	drag_start_pos = button.global_position + button.size / 2
	
	# Visual feedback on source button
	button.modulate = Color.GRAY
	
	print("Started dragging: ", type, " from position: ", drag_start_pos)
	queue_redraw()

func _stop_dragging():
	print("Stopping drag")
	if drag_button:
		# Restore button color if not connected
		if drag_type == "template" and not template_connected:
			drag_button.modulate = Color.WHITE
		elif drag_type == "static" and not static_connected:
			drag_button.modulate = Color.WHITE
	
	is_dragging = false
	drag_button = null
	drag_type = ""
	queue_redraw()

func _handle_drop():
	if not is_dragging:
		return
	
	var mouse_pos = get_global_mouse_position()
	print("Handling drop at: ", mouse_pos)
	
	if _is_mouse_over_settings(mouse_pos):
		print("Successful drop on settings!")
		_make_connection()
	else:
		print("Failed drop - not over settings")
		_update_feedback_label("❌ Please drag to the settings.py file!", Color.ORANGE)

func _make_connection():
	var start_pos = drag_start_pos
	var end_pos = settings_py_button.global_position + settings_py_button.size / 2
	
	print("Making connection from ", start_pos, " to ", end_pos)
	
	if drag_type == "template" and not template_connected:
		template_connected = true
		template_line_start = start_pos
		template_line_end = end_pos
		drag_button.modulate = Color.LIGHT_GREEN
		_update_feedback_label("✅ Template connected to settings.py!", Color.GREEN)
		print("Template connected!")
		
	elif drag_type == "static" and not static_connected:
		static_connected = true
		static_line_start = start_pos
		static_line_end = end_pos
		drag_button.modulate = Color.LIGHT_GREEN
		_update_feedback_label("✅ Static files connected to settings.py!", Color.GREEN)
		print("Static connected!")
	
	queue_redraw()
	_check_all_connected()

# --- Feedback Logic ---
func _update_feedback_label(message: String, color: Color = Color.WHITE):
	feedback_label.text = message
	feedback_label.modulate = color
	feedback_timer.start()

func _on_feedback_timer_timeout():
	if not (template_connected and static_connected):
		feedback_label.text = ""
		feedback_label.modulate = Color.WHITE

func _check_all_connected():
	if template_connected and static_connected:
		instruction_label.text = "🎉 Success! Both connections made.\nRedirecting to Template Repair..."
		instruction_label.modulate = Color.GREEN
		feedback_label.text = ""
		settings_py_button.modulate = Color.LIGHT_GREEN

		# Disable further interaction
		robot_template_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		robot_static_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		settings_py_button.mouse_filter = Control.MOUSE_FILTER_IGNORE

		print("All connections complete! Starting delay before next scene...")

		# Dynamically create a timer for delay
		var delay_timer = Timer.new()
		delay_timer.wait_time = 2.0
		delay_timer.one_shot = true
		delay_timer.timeout.connect(_on_delay_timer_timeout)
		add_child(delay_timer)
		delay_timer.start()

func _on_delay_timer_timeout():
	print("Delay complete! Changing scene...")
	get_tree().change_scene_to_file("res://scenes/Levels/Chapter 2/chapter_2_world_part_5.tscn")


# Force redraw every frame while debugging
func _process(_delta):
	if is_dragging or template_connected or static_connected:
		queue_redraw()
