extends Node2D
## Echo Foundry: a rewind echo holds a temporary bridge open.
const ECHO_DURATION := 10.0
const PLATE := Vector2(784, 96)
const BRIDGE_RECT := Rect2(896, 96, 224, 12)
const GATE_RECT := Rect2(860, -72, 16, 168)
const ATLAS := preload("res://Assets/Level3/Assets.png")
const FONT := preload("res://front end/assets/PixelifySans.ttf")

@onready var player = $Player
@onready var hud = get_node_or_null("GameHUD") if has_node("GameHUD") else get_tree().current_scene.get_node("GameHUD")
@onready var timer = hud.get_node("Interface/LevelTimer")
var echo_left := 0.0
var echo_activated := false
var was_rewinding := false
var gate_shape: CollisionShape2D
var bridge_shape: CollisionShape2D
var ghost: AnimatedSprite2D
var status: Label
var checkpoint := Vector2(272, 31)
var damage_cooldown := 0.0
var original_clear: Color

func _ready() -> void:
	original_clear = RenderingServer.get_default_clear_color()
	RenderingServer.set_default_clear_color(Color(0.025, 0.02, 0.035, 1.0))
	process_physics_priority = 3
	_build_terrain_collisions()
	gate_shape = _solid(self, GATE_RECT)
	bridge_shape = _solid(self, BRIDGE_RECT)
	bridge_shape.disabled = true
	ghost = player.get_node("AnimatedSprite2D").duplicate()
	ghost.modulate = Color(0.35, 1.0, 0.85, 0.6)
	ghost.visible = false
	ghost.pause()
	add_child(ghost)
	status = Label.new()
	status.add_theme_font_override("font", FONT)
	status.add_theme_font_size_override("font_size", 20)
	status.add_theme_color_override("font_color", Color("ead8b0"))
	status.add_theme_color_override("font_outline_color", Color("211b27"))
	status.add_theme_constant_override("outline_size", 5)
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	status.position = Vector2(260, 85)
	status.size = Vector2(680, 82)
	hud.add_child(status)
	timer.level_seconds = 180.0
	timer.time_left = 180.0
	$Portal.monitoring = false

func _exit_tree() -> void:
	if is_instance_valid(status):
		status.queue_free()
	RenderingServer.set_default_clear_color(original_clear)

func _solid(parent: Node, rect: Rect2, one_way := false) -> CollisionShape2D:
	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	parent.add_child(body)
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = rect.size
	shape.shape = box
	shape.position = rect.get_center()
	shape.one_way_collision = one_way
	body.add_child(shape)
	return shape

func _build_terrain_collisions() -> void:
	var rows: Dictionary = {}
	for layer in [$Map/TerrainFill, $Map/Layer_0_0]:
		for cell in layer.get_used_cells():
			if layer == $Map/TerrainFill and layer.get_cell_atlas_coords(cell).x == 4:
				continue
			if not rows.has(cell.y):
				rows[cell.y] = []
			rows[cell.y].append(cell.x)
	for y in rows:
		var xs: Array = rows[y]
		xs.sort()
		var start: int = xs[0]
		var last := start
		for index in range(1, xs.size() + 1):
			if index < xs.size() and xs[index] <= last + 1:
				last = xs[index]
				continue
			_solid($Map, Rect2(start * 16, int(y) * 16, (last - start + 1) * 16, 16))
			if index < xs.size():
				start = xs[index]
				last = start
	for decoration in $Map/Decorations.get_children():
		if decoration.name.begins_with("Timber") or decoration.name.begins_with("NotchBridge"):
			_solid($Map, Rect2(decoration.position, Vector2(decoration.region_rect.size.x, 4)), true)
	# A staircase of one-way mine beams lets a fallen player return to the surface.
	for rect in [Rect2(928, 320, 64, 8), Rect2(1000, 248, 64, 8), Rect2(1068, 176, 52, 8)]:
		_solid(self, rect, true)

func _physics_process(delta: float) -> void:
	damage_cooldown = maxf(0.0, damage_cooldown - delta)
	var feet: Vector2 = player.global_position + Vector2(0, 64.5)
	var on_plate := absf(feet.x - PLATE.x) < 28.0 and absf(feet.y - PLATE.y) < 10.0
	var rewinding: bool = not player.is_rewinding and Input.is_action_pressed("rewind")
	if rewinding and not was_rewinding and on_plate:
		_activate_echo()
	was_rewinding = rewinding
	echo_left = maxf(0.0, echo_left - delta)
	var active := echo_left > 0.0
	# Do not close a gate through the player's collision shape.
	gate_shape.set_deferred("disabled", active or GATE_RECT.grow(22).has_point(feet))
	bridge_shape.set_deferred("disabled", not active)
	ghost.visible = active
	if active:
		ghost.modulate.a = minf(0.65, echo_left * 0.3)
	if player.global_position.x > 1170.0 and player.is_on_floor() and feet.y < 160.0:
		checkpoint = Vector2(1200, 31)
	if player.global_position.y > 850.0 or player.global_position.x < -100.0:
		take_hit()
	if active:
		status.text = "ECHO HOLDING  %.1fs\nCross the bridge before it fades!" % echo_left
	elif echo_activated:
		status.text = "ECHO FOUNDRY  /  LEVEL 3\nReach the portal. Dash through the time wardens."
	elif on_plate and player.positionsX.size() < player.MAX_HISTORY:
		status.text = "ECHO PLATE\nWait a moment to record enough history."
	elif on_plate:
		status.text = "ECHO PLATE\nHold SPACE now to leave an echo. Release, then cross!"
	else:
		status.text = "ECHO FOUNDRY  /  LEVEL 3\nStand on the glowing plate, then rewind to leave an echo."
	$Portal.set_deferred("monitoring", echo_activated)
	queue_redraw()

func _activate_echo() -> void:
	echo_left = ECHO_DURATION
	echo_activated = true
	ghost.global_position = player.global_position
	ghost.frame = player.get_node("AnimatedSprite2D").frame
	ghost.flip_h = player.get_node("AnimatedSprite2D").flip_h

func take_hit() -> void:
	if damage_cooldown > 0.0:
		return
	damage_cooldown = 1.5
	player.global_position = checkpoint
	player.velocity = Vector2.ZERO
	player.positionsX.clear()
	player.positionsY.clear()
	player.is_rewinding = true
	player.i = 0
	player.r = 0
	player.get_node("GlitchShader").hide()
	player.get_node("CollisionShape2D").set_deferred("disabled", false)
	timer.time_left = maxf(0.0, timer.time_left - 5.0)

func _draw() -> void:
	var active := echo_left > 0.0
	var tint := Color("70edd2") if active else Color("a57ce0")
	# Plate, frame, beams, and gate are gameplay foreground, with no background art.
	draw_rect(Rect2(756, 91, 56, 5), tint)
	draw_rect(Rect2(762, 86, 44, 5), tint.darkened(0.45))
	for x in range(0, 224, 32):
		draw_texture_rect_region(ATLAS, Rect2(896 + x, 96, 32, 16), Rect2(96, 96, 16, 8), Color(0.5, 1, 0.85, 1) if active else Color(0.6, 0.5, 0.8, 0.16))
	if not gate_shape or not gate_shape.disabled:
		draw_rect(GATE_RECT, Color("3c294a"))
		for y in range(-68, 96, 16):
			draw_rect(Rect2(862, y, 12, 5), tint)
	for rect in [Rect2(928, 320, 64, 8), Rect2(1000, 248, 64, 8), Rect2(1068, 176, 52, 8)]:
		draw_texture_rect_region(ATLAS, rect, Rect2(96, 96, 32, 8))
	if echo_activated:
		draw_circle(Vector2(1200, 92), 5, Color("70edd2"))
