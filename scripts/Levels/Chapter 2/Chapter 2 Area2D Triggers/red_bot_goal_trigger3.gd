# red_bot_goal_trigger3.gd
extends Area2D

@onready var room_function_ui = get_node("../UILayer/RoomContactFunctionMinigame1")
@onready var respawn_ui = get_node("../UILayer/RespawnUI")
@onready var instructions_ui = get_node("../UILayer/Chapter2Minigame1Instructions")

func _ready():
	print("[RedGoal] _ready called")
	if not respawn_ui:
		printerr("[RedGoal] ERROR: RespawnUI not found!")
	else:
		print("[RedGoal] RespawnUI found.")

	if not instructions_ui:
		printerr("[RedGoal] ERROR: Instructions UI not found!")
	else:
		print("[RedGoal] Instructions UI found.")
	
	body_entered.connect(_on_body_entered)
	print("[RedGoal] body_entered signal connected.")

func _on_body_entered(body):
	print("[RedGoal] body_entered by: ", body.name)
	
	if body.name == "DeliveryBot1":
		print("[RedGoal] Red bot reached - wrong destination!")

		body.disable_movement()
		print("[RedGoal] Movement disabled for DeliveryBot1.")

		if instructions_ui and instructions_ui.has_method("show_error_message"):
			instructions_ui.show_error_message("Wrong Views Room! This URL doesn't belong here.")
			print("[RedGoal] Error message shown.")
		else:
			printerr("[RedGoal] ERROR: show_error_message method missing or instructions_ui null.")
		
		await get_tree().create_timer(1.0).timeout

		if respawn_ui:
			respawn_ui.show_respawn_menu()
			print("[RedGoal] Respawn UI shown.")
		else:
			printerr("[RedGoal] ERROR: respawn_ui is null.")
