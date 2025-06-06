# yellow_bot_goal_trigger.gd
extends Area2D

@onready var room_function_ui = get_node("../UILayer/RoomHomeFunctionMinigame1")
@onready var respawn_ui = get_node("../UILayer/RespawnUI")
@onready var instructions_ui = get_node("../UILayer/Chapter2Minigame1Instructions")

func _ready():
	print("[YellowGoal] _ready called")
	if not room_function_ui:
		printerr("[YellowGoal] ERROR: Room Function UI not found!")
	else:
		print("[YellowGoal] Room Function UI found.")

	if not instructions_ui:
		printerr("[YellowGoal] ERROR: Instructions UI not found!")
	else:
		print("[YellowGoal] Instructions UI found.")

	body_entered.connect(_on_body_entered)
	print("[YellowGoal] body_entered signal connected.")

func _on_body_entered(body):
	print("[YellowGoal] body_entered by: ", body.name)

	if body.name == "DeliveryBot2":
		print("[YellowGoal] Yellow bot reached correct destination!")

		body.disable_movement()
		print("[YellowGoal] Movement disabled for DeliveryBot2.")

		if instructions_ui and instructions_ui.has_method("show_success_message"):
			instructions_ui.show_success_message("Congratulations! You've reached the correct destination!")
			print("[YellowGoal] Success message shown.")
		else:
			printerr("[YellowGoal] ERROR: show_success_message method missing or instructions_ui null.")
		
		await get_tree().create_timer(1.5).timeout
		show_room_function_quiz()

func show_room_function_quiz():
	if instructions_ui:
		instructions_ui.visible = false
	
	if room_function_ui:
		room_function_ui.visible = true
		room_function_ui.start_quiz()
		print("[YellowGoal] Room function quiz started.")
	else:
		printerr("[YellowGoal] ERROR: Room function UI is null.")
