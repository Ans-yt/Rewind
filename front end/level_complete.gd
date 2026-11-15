extends CanvasLayer

var time_left := 0.0
var completed_scene := ""
var completed_level_number := 1
const LEVELS := ["res://Scenes/level_1.tscn", "res://Scenes/level_2.tscn", "res://Scenes/level_3.tscn"]

func _ready() -> void:
	get_tree().paused = true
	var main := get_tree().current_scene
	if completed_scene.is_empty():
		completed_scene = main.scene_file_path
	if main.has_method("load_level"):
		completed_level_number = main.current_level_number
	else:
		completed_level_number = maxi(1, LEVELS.find(completed_scene) + 1)
	if completed_level_number == 3:
		$Overlay/Next.text = "Back to menu"
	var seconds := ceili(time_left)
	$Overlay/Message.text = "Congratulations!\nTime left: %02d:%02d" % [floori(seconds / 60.0), seconds % 60]
	$Overlay/Next.pressed.connect(show_next_level)
	$Overlay/Replay.pressed.connect(replay_level)
	$Overlay/Menu.pressed.connect(return_to_menu)

func show_next_level() -> void:
	if completed_level_number >= LEVELS.size():
		return_to_menu()
		return
	var main := get_tree().current_scene
	if main.has_method("load_level"):
		click_sound()
		main.load_level(completed_level_number + 1)
		queue_free()
	else:
		leave_screen(LEVELS[completed_level_number])

func replay_level() -> void:
	var main := get_tree().current_scene
	if main.has_method("restart_level"):
		click_sound()
		main.restart_level()
		queue_free()
	else:
		leave_screen(completed_scene)

func return_to_menu() -> void:
	leave_screen("res://front end/menu.tscn")

func click_sound() -> void:
	var click := $ClickSound
	click.reparent(get_tree().root)
	click.finished.connect(click.queue_free)
	click.play()

func leave_screen(scene_path: String) -> void:
	click_sound()
	get_tree().paused = false
	get_tree().change_scene_to_file(scene_path)
	queue_free()
