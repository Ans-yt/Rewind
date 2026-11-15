extends Control

@export var level_seconds := 230.0

@onready var level = get_parent().get_parent().get_parent()
var player: Node2D = null

var time_left := 0.0
var wizard_linger := 0.0
var drain_rate := 1.0
var game_over := false

func _ready() -> void:
	process_physics_priority = 2
	reset_timer(level_seconds)
	$GameOver/Restart.pressed.connect(restart_level)
	update_display()

func reset_timer(seconds: float = -1.0) -> void:
	if seconds >= 0.0:
		level_seconds = seconds
	time_left = level_seconds
	wizard_linger = 0.0
	drain_rate = 1.0
	game_over = false
	player = null
	$GameOver.hide()
	update_display()

func resolve_player() -> Node2D:
	# A loader can replace its player without replacing this persistent HUD.
	if is_instance_valid(level) and level.has_method("load_level"):
		var active = level.current_level_instance
		if is_instance_valid(active):
			return active.get_node_or_null("Player")
	if is_instance_valid(level):
		var local_player := level.get_node_or_null("Player")
		if local_player != null:
			return local_player
	return get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	player = resolve_player()
	if game_over or get_tree().paused or not is_instance_valid(player):
		return
	var hit := false
	for wizard in get_tree().get_nodes_in_group("Wizards"):
		if wizard.attacking and wizard.time_icon.visible:
			hit = true
			break
	var rewinding: bool = Input.is_action_pressed("rewind") and not player.is_rewinding and player.positionsX.size() == player.MAX_HISTORY and player.i > 0 and player.i <= player.r + 1
	var wizard_seconds := delta if hit else minf(delta, wizard_linger)
	wizard_linger = 3.0 if hit else maxf(0.0, wizard_linger - delta)
	var base_rate := 1.5 if rewinding else 1.0
	drain_rate = base_rate + (0.5 if hit or wizard_linger > 0.0 else 0.0)
	time_left = maxf(0.0, time_left - delta * base_rate - wizard_seconds * 0.5)
	update_display()
	if time_left <= 0.0:
		game_over = true
		$GameOver.show()
		get_tree().paused = true

func update_display() -> void:
	var seconds := ceili(time_left)
	$Board/Time.text = "%02d:%02d" % [floori(seconds / 60.0), seconds % 60]
	$Board/Rate.text = str(drain_rate).trim_suffix(".0") + "x"
	$Board/Time.modulate = Color("ffb77b") if time_left <= 30.0 else Color.WHITE

func restart_level() -> void:
	get_tree().paused = false
	get_parent().restart_level()
