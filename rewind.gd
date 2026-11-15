extends Node2D

@onready var level_container: Node2D = $LevelContainer
var current_level_instance: Node = null
var current_level_number := 1
const LEVEL_PATHS := ["res://Scenes/level_1.tscn", "res://Scenes/level_2.tscn", "res://Scenes/level_3.tscn"]

func _ready() -> void:
	load_level(1)

func load_level(level_number: int) -> void:
	if level_number < 1 or level_number > LEVEL_PATHS.size():
		push_error("Level not found: %d" % level_number)
		return
	get_tree().paused = false
	if is_instance_valid(current_level_instance):
		# Exit the old level before adding the next player or its wizard group members.
		level_container.remove_child(current_level_instance)
		current_level_instance.queue_free()
		current_level_instance = null
	current_level_number = level_number
	$ParallaxBackground.visible = level_number != 3
	var level_scene: PackedScene = load(LEVEL_PATHS[level_number - 1])
	current_level_instance = level_scene.instantiate()
	# Standalone level HUDs are only needed when the level is run directly with F6.
	var local_hud := current_level_instance.get_node_or_null("GameHUD")
	if local_hud != null:
		current_level_instance.remove_child(local_hud)
		local_hud.free()
	# Level 2 contains its own background; use the shared background in this wrapper.
	var local_background := current_level_instance.get_node_or_null("ParallaxBackground")
	if local_background != null:
		current_level_instance.remove_child(local_background)
		local_background.free()
	level_container.add_child(current_level_instance)
	$GameHUD/Interface/LevelTimer.reset_timer(180.0 if level_number == 3 else 230.0)

func restart_level() -> void:
	load_level(current_level_number)
