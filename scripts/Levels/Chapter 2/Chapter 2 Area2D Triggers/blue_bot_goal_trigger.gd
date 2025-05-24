# blue_bot_goal_trigger.gd
extends Area2D

@onready var room_function_ui = get_node("../UILayer/RoomHomeFunctionMinigame1")
@onready var respawn_ui = get_node("../UILayer/RespawnUI")
@onready var instructions_ui = get_node("../UILayer/Chapter2Minigame1Instructions")

func _ready():
	print("[BlueGoal] _ready called")
	if not respawn_ui:
		printerr("[BlueGoal] ERROR: RespawnUI not found!")
	else:
		print("[BlueGoal] RespawnUI found.")

	if not instructions_ui:
		printerr("[BlueGoal] ERROR: Instructions UI not found!")
	else:
		print("[BlueGoal] Instructions UI found.")
	
	body_entered.connect(_on_body_entered)
	print("[BlueGoal] body_entered signal connected.")

func _on_body_entered(body):
	print("[BlueGoal] body_entered by: ", body.name)
	
	if body.name == "DeliveryBot2":
		print("[BlueGoal] Blue bot reached - wrong destination!")

		body.disable_movement()
		print("[BlueGoal] Movement disabled for DeliveryBot2.")

		if instructions_ui and instructions_ui.has_method("show_error_message"):
			instructions_ui.show_error_message("Wrong Views Room! This URL doesn't belong here.")
			print("[BlueGoal] Error message shown.")
		else:
			printerr("[BlueGoal] ERROR: show_error_message method missing or instructions_ui null.")
		
		await get_tree().create_timer(1.0).timeout

		if respawn_ui:
			respawn_ui.show_respawn_menu()
			print("[BlueGoal] Respawn UI shown.")
		else:
			printerr("[BlueGoal] ERROR: respawn_ui is null.")
