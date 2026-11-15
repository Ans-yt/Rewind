extends AudioStreamPlayer

const TRACKS = [
	preload("res://sfx/Clement Panchout _ 2022 _ By the river.wav"),
	preload("res://sfx/Time Flies _Clement Panchout _2016.wav")
]
const TRACK_LEVELS = [-21.0, -23.7]

var track_index := -1
var master_volume := 1.0
var muted := false

static func start(tree: SceneTree) -> void:
	if tree.root.has_node("BackgroundMusic"):
		return
	var music := AudioStreamPlayer.new()
	music.set_script(load("res://front end/music.gd"))
	music.name = "BackgroundMusic"
	music.process_mode = Node.PROCESS_MODE_ALWAYS
	tree.root.add_child.call_deferred(music)

func _ready() -> void:
	var config := ConfigFile.new()
	if config.load("user://audio.cfg") == OK:
		master_volume = clampf(float(config.get_value("audio", "volume", 1.0)), 0.0, 1.0)
		muted = bool(config.get_value("audio", "muted", false))
	apply_volume()
	finished.connect(play_next)
	play_next()

func play_next() -> void:
	track_index = randi_range(0, 1) if track_index < 0 else 1 - track_index
	stream = TRACKS[track_index]
	stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
	volume_db = TRACK_LEVELS[track_index]
	play()

func apply_volume() -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(master_volume, 0.0001)))
	AudioServer.set_bus_mute(0, muted or master_volume == 0.0)

func save_settings() -> void:
	apply_volume()
	var config := ConfigFile.new()
	config.set_value("audio", "volume", master_volume)
	config.set_value("audio", "muted", muted)
	config.save("user://audio.cfg")
