extends Area2D

var animation_time := 0.0
var used := false

func _ready() -> void:
	body_entered.connect(enter_portal)

func _process(delta: float) -> void:
	animation_time += delta
	$Sprite2D.frame = int(animation_time / 0.1) % 4

func enter_portal(body: Node2D) -> void:
	if used or get_tree().paused or body != get_parent().get_node_or_null("Player"):
		return
	var main := get_tree().current_scene
	var timer = main.get_node_or_null("GameHUD/Interface/LevelTimer") if main else null
	if timer == null:
		timer = get_parent().get_node_or_null("GameHUD/Interface/LevelTimer")
	if timer == null or timer.game_over:
		return
	used = true
	get_tree().paused = true
	var screen := preload("res://front end/level_complete.tscn").instantiate()
	screen.time_left = timer.time_left
	# Identify the actual level rather than the wrapper containing it.
	screen.completed_scene = get_parent().scene_file_path
	get_tree().root.add_child.call_deferred(screen)
