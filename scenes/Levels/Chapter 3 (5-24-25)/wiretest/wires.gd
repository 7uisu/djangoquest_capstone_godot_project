extends Node2D

@onready var wire_game = get_parent()

func _draw():
	for line in wire_game.connected_lines:
		var color = Color.YELLOW # <-- default color is YELLOW before validation!

		if line["is_correct"] == true:
			color = Color.GREEN
		elif line["is_correct"] == false:
			color = Color.RED
		# else: still yellow if not validated

		draw_line(line["start"], line["end"], color, 4)

	# Draw dragging line (while dragging)
	if wire_game.dragging and wire_game.start_button:
		draw_line(wire_game.start_position, wire_game.temp_line_end, Color.YELLOW, 2)
