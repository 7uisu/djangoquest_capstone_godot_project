extends Node2D

@onready var labels = [
	$CanvasLayer_for_UI/minigame_ui/view_area/Label,
	$CanvasLayer_for_UI/minigame_ui/view_area/Label2,
	$CanvasLayer_for_UI/minigame_ui/view_area/Label3
]

@onready var buttons = [
	$CanvasLayer_for_UI/minigame_ui/url_area/url1,
	$CanvasLayer_for_UI/minigame_ui/url_area/url2,
	$CanvasLayer_for_UI/minigame_ui/url_area/url3
]

@onready var feedback_label = $CanvasLayer_for_UI/minigame_ui/feedback

var active_index := -1
var game_timer := Timer.new()
var round_timer := Timer.new()
var phase_timer := Timer.new()
var lives := 3
var round_duration := 3.0  # How fast a player must respond (gets shorter)
var phase := 1

func _ready():
	add_child(game_timer)
	add_child(round_timer)
	add_child(phase_timer)

	for i in range(buttons.size()):
		buttons[i].pressed.connect(_on_button_pressed.bind(i))

	game_timer.wait_time = 20
	game_timer.one_shot = true
	game_timer.timeout.connect(_on_phase_end)

	round_timer.one_shot = true
	round_timer.timeout.connect(_on_round_timeout)

	phase_timer.one_shot = true
	phase_timer.timeout.connect(_start_new_phase)  # ✅ this method now exists

	_start_phase()

func _start_phase():
	feedback_label.text = "Phase %d starts!" % phase
	game_timer.start()
	_start_new_round()

func _start_new_phase():
	feedback_label.text = "Phase %d starts!" % phase
	game_timer.start()
	_start_new_round()

func _start_new_round():
	for label in labels:
		label.modulate = Color(1, 1, 1)

	active_index = randi() % labels.size()
	var glowing_label = labels[active_index]
	glowing_label.modulate = Color(1, 1, 0)  # Yellow glow

	feedback_label.text = "Which label is glowing?"

	round_timer.start(round_duration)

func _on_button_pressed(index):
	if active_index == -1 or round_timer.time_left == 0:
		return

	round_timer.stop()  # stop timeout if they clicked
	if index == active_index:
		feedback_label.text = "Correct!"
	else:
		lives -= 1
		feedback_label.text = "Wrong! Lives left: %d" % lives

	_check_game_state()

func _on_round_timeout():
	feedback_label.text = "Too slow! -1 life"
	lives -= 1
	_check_game_state()

func _check_game_state():
	if lives <= 0:
		feedback_label.text = "Game Over"
		return
	await get_tree().create_timer(0.5).timeout
	_start_new_round()

func _on_phase_end():
	feedback_label.text = "Phase %d ended. Get ready..." % phase
	phase += 1
	round_duration = max(1.0, round_duration - 0.5)  # Game speeds up
	phase_timer.start(3)  # Wait 3 seconds, then start next phase
