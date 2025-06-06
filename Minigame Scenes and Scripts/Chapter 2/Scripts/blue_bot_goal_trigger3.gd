# blue_bot_goal_trigger3.gd
extends Area2D

@onready var room_function_ui = get_node("../UILayer/RoomAboutFunctionMinigame1")
@onready var respawn_ui = get_node("../UILayer/RespawnUI")
@onready var instructions_ui = get_node("../UILayer/Chapter2Minigame1Instructions")

func _ready():
	print("[BlueGoal] _ready called")
	if not room_function_ui:
		printerr("[BlueGoal] ERROR: Room Function UI not found!")
	else:
		print("[BlueGoal] Room Function UI found.")

	if not instructions_ui:
		printerr("[BlueGoal] ERROR: Instructions UI not found!")
	else:
		print("[BlueGoal] Instructions UI found.")

	body_entered.connect(_on_body_entered)
	print("[BlueGoal] body_entered signal connected.")

func _on_body_entered(body):
	print("[BlueGoal] body_entered by: ", body.name)

	if body.name == "DeliveryBot1":
		print("[BlueGoal] Blue bot reached correct destination!")

		body.disable_movement()
		print("[BlueGoal] Movement disabled for DeliveryBot1.")

		if instructions_ui and instructions_ui.has_method("show_success_message"):
			instructions_ui.show_success_message("Great job! You've found the correct view room!")
			print("[BlueGoal] Success message shown.")
		else:
			printerr("[BlueGoal] ERROR: show_success_message method missing or instructions_ui null.")
		
		await get_tree().create_timer(1.5).timeout
		show_room_function_quiz()

func show_room_function_quiz():
	if instructions_ui:
		instructions_ui.visible = false
	
	if room_function_ui:
		room_function_ui.visible = true
		room_function_ui.start_quiz()
		print("[BlueGoal] Room function quiz started.")
	else:
		printerr("[BlueGoal] ERROR: Room function UI is null.")
