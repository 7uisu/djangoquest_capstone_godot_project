#bulletin_board_ui.gd
extends Control

signal closed

@onready var player = get_node_or_null("/root/Playground/Player")

func _ready() -> void:
	print("[BulletinBoardUI] _ready()")
	self.visible = false
	
	if not player:
		printerr("[BulletinBoardUI] Player node not found. Movement control might fail.")

func _input(event: InputEvent) -> void:
	if not visible:
		return
		
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_accept"):
		print("[BulletinBoardUI] Close key pressed")
		close_bulletin()

func show_bulletin() -> void:
	print("[BulletinBoardUI] show_bulletin()")
	if player and "can_move" in player:
		player.can_move = false
	
	self.visible = true
	grab_focus()

func close_bulletin() -> void:
	print("[BulletinBoardUI] close_bulletin()")
	if player and "can_move" in player:
		player.can_move = true
	
	self.visible = false
	emit_signal("closed")
