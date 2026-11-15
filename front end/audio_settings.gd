extends CanvasLayer

var music: AudioStreamPlayer
var was_paused := false

func _ready() -> void:
	was_paused = get_tree().paused
	get_tree().paused = true
	preload("res://front end/music.gd").start(get_tree())
	await get_tree().process_frame
	music = get_tree().root.get_node("BackgroundMusic")
	$Overlay/Volume.value = music.master_volume * 100.0
	$Overlay/Mute.button_pressed = music.muted
	update_labels()
	$Overlay/Volume.value_changed.connect(change_volume)
	$Overlay/Mute.toggled.connect(change_mute)
	$Overlay/Close.pressed.connect(close_settings)
	$Overlay/Close.grab_focus()

func change_volume(value: float) -> void:
	music.master_volume = value / 100.0
	music.save_settings()
	update_labels()

func change_mute(value: bool) -> void:
	music.muted = value
	music.save_settings()
	update_labels()

func update_labels() -> void:
	$Overlay/Percentage.text = "%d%%" % roundi(music.master_volume * 100.0)
	$Overlay/MuteLabel.text = "Muted" if music.muted else "Sound on"

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close_settings()

func close_settings() -> void:
	get_tree().paused = was_paused
	queue_free()
