extends CanvasLayer

var time_left := 0.0

func _ready() -> void:
	get_tree().paused = true
	var seconds := ceili(time_left)
	$Overlay/Message.text = "Congratulations!\nTime left: %02d:%02d" % [floori(seconds / 60.0), seconds % 60]
	$Overlay/Next.pressed.connect(show_next_level)
	$Overlay/Replay.pressed.connect(replay_level)
	$Overlay/Menu.pressed.connect(return_to_menu)

func show_next_level() -> void:
	$ClickSound.play()
	$Overlay/Title.text = "LEVEL 2"
	$Overlay/Message.text = "Next level placeholder.\nMore to come!"
	$Overlay/Next.text = "Coming soon"
	$Overlay/Next.disabled = true
	leave_screen("res://Scenes/level_2.tscn")
	

func replay_level() -> void:
	leave_screen("res://rewind.tscn")

func return_to_menu() -> void:
	leave_screen("res://front end/menu.tscn")

func leave_screen(scene_path: String) -> void:
	var click := $ClickSound
	click.reparent(get_tree().root)
	click.finished.connect(click.queue_free)
	click.play()
	get_tree().paused = false
	get_tree().change_scene_to_file(scene_path)
	queue_free()
