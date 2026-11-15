extends Control

const SKY = preload("res://Assets/Grassy-Meadow-Parallax-Background-v1/Grassy-Meadow-Parallax-Background-v1/Parallax Background/1-sky.png")
const CLOUDS = preload("res://Assets/Grassy-Meadow-Parallax-Background-v1/Grassy-Meadow-Parallax-Background-v1/Parallax Background/2-clouds.png")
const TILES = preload("res://Assets/Tiles/Assets/Assets.png")

const BOARD_FONT = preload("res://front end/assets/Lockergnome.otf")
const SIGN = preload("res://front end/assets/panneaux.png")
const HAND = preload("res://front end/assets/main.png")
const LOGO = preload("res://front end/assets/logo.png")
const HOURGLASS = preload("res://front end/assets/sablier.png")
const PLAYER = preload("res://Assets/Sprites/walk1.png")

var sky_offset := 0.0
var play_time := -1.0

var menu_scale := Vector2.ONE
var menu_offset := Vector2.ZERO
var selected := -1
var notice := ""
var labels := ["TUTORIAL", "PLAY", "SETTINGS"] # le boutton tuto il sert a r mais boonn

func _ready() -> void:
	preload("res://front end/music.gd").start(get_tree())
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mouse_filter = Control.MOUSE_FILTER_STOP
	resized.connect(update_menu_layout)
	update_menu_layout()

func update_menu_layout() -> void:
	var scale_factor := maxf(minf(size.x / 1200.0, size.y / 675.0), 0.001)
	menu_scale = Vector2.ONE * scale_factor
	menu_offset = (size - Vector2(1200, 675) * menu_scale) * Vector2(0.5, 1.0)
	queue_redraw()

func _process(delta: float) -> void:
	sky_offset = fmod(sky_offset + delta * 8.0, 1200.0)
	if play_time >= 0.0:
		play_time += delta
		if play_time >= 3.4:
			set_process(false)
			get_tree().change_scene_to_file("res://rewind.tscn")
			return
	queue_redraw()

func _draw() -> void:
	draw_set_transform(Vector2.ZERO)
	draw_texture_rect_region(SKY, Rect2(Vector2.ZERO, size), Rect2(0, 0, 1920, 90))
	draw_set_transform(menu_offset, 0.0, menu_scale)
	var left := -menu_offset.x / menu_scale.x
	var right := (size.x - menu_offset.x) / menu_scale.x
	for x in range(floori(left / 1200.0) * 1200, ceili(right / 1200.0) * 1200 + 1200, 1200):
		draw_texture_rect(CLOUDS, Rect2(x - sky_offset, 90, 1200, 675), false)

	for x in range(floori(left / 48.0) * 48, ceili(right / 48.0) * 48, 48):
		draw_texture_rect_region(TILES, Rect2(x, 602, 48, 48), Rect2(48, 0, 16, 16))
		draw_texture_rect_region(TILES, Rect2(x, 650, 48, 48), Rect2(48, 16, 16, 16))

	draw_texture_rect(SIGN, Rect2(426, 240, 348, 368), false)
	draw_texture_rect(LOGO, Rect2(490, -18, 220, 210), false)

	for i in range(3):
		var y = [284, 367, 464][i]
		var angle = [0.05, -0.038, 0.0][i]
		var color := Color("fff0c4") if selected == i else Color("f7dfac")
		var text_width := BOARD_FONT.get_string_size(labels[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 32).x
		var baseline := (BOARD_FONT.get_ascent(32) - BOARD_FONT.get_descent(32)) / 2.0
		draw_set_transform(menu_offset + Vector2(595, y) * menu_scale, angle, menu_scale)
		draw_string(BOARD_FONT, Vector2(-text_width / 2.0, baseline), labels[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 32, color)
	draw_set_transform(menu_offset, 0.0, menu_scale)

	draw_intro()

	if notice != "":
		draw_rect(Rect2(395, 555, 410, 33), Color(0.14, 0.22, 0.18, 0.8))
		draw_string(ThemeDB.fallback_font, Vector2(405, 578), notice, HORIZONTAL_ALIGNMENT_CENTER, 390, 17, Color.WHITE)

func start_play() -> void:
	if play_time >= 0.0:
		return
	play_time = 0.0
	selected = -1
	notice = ""

func draw_intro() -> void:
	var center := Vector2(110, 175)
	var hand_offset := Vector2.ZERO
	var angle := 0.0
	var squash := Vector2.ONE
	var growth := 0.0
	var awake := 0.0
	var frame := 0

	if play_time >= 0.0:
		frame = int(play_time / 0.08) % 8
		if play_time < 0.5:
			var shake := sin(play_time * 65.0)
			angle = shake * 0.12
			center.x += shake * 3.0
		elif play_time < 1.2:
			var fall := (play_time - 0.5) / 0.7
			center = Vector2(lerpf(110, 260, fall), lerpf(175, 558, fall * fall))
			angle = sin(fall * PI) * 0.5
		else:
			center = Vector2(260, 558)
			frame = 0
			var impact := clampf((play_time - 1.2) / 0.3, 0.0, 1.0)
			var compression := sin(impact * PI)
			squash = Vector2(1.0 + compression * 0.2, 1.0 - compression * 0.2)
			center.y += compression * 8.0
			growth = smoothstep(1.55, 2.35, play_time)
			awake = smoothstep(1.7, 2.15, play_time)
			center.y -= growth * 18.5
		if play_time >= 0.5:
			var release := clampf((play_time - 0.5) / 0.5, 0.0, 1.0)
			hand_offset = Vector2(release * 30.0, -release * release * (220.0 + menu_offset.y / menu_scale.y))

	draw_set_transform(menu_offset + center * menu_scale, angle, menu_scale * squash)
	if growth > 0.0:
		draw_texture_rect_region(PLAYER, Rect2(-31.25, 43.75, 62.5, 18.75 * growth), Rect2(118, 186, 20, 6))
	if awake < 1.0:
		draw_texture_rect_region(HOURGLASS, Rect2(-50, -50, 100, 100), Rect2(frame * 192, 0, 192, 192), Color(1, 1, 1, 1.0 - awake))
	if awake > 0.0:
		draw_texture_rect_region(PLAYER, Rect2(-31.25, -43.75, 62.5, 87.5), Rect2(118, 158, 20, 28), Color(1, 1, 1, awake))
	draw_set_transform(menu_offset, 0.0, menu_scale)
	draw_texture_rect(HAND, Rect2(Vector2(-20, -60) + hand_offset, Vector2(256, 256)), false)
	if play_time > 3.0:
		draw_set_transform(Vector2.ZERO)
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.0, 0.0, 0.0, clampf((play_time - 3.0) / 0.4, 0.0, 1.0)))

func _gui_input(event: InputEvent) -> void:
	if play_time >= 0.0 or not event is InputEventMouse:
		return
	var pointer: Vector2 = (event.position - menu_offset) / menu_scale
	var hovered := -1
	for i in range(3):
		if Rect2(442, [240, 332, 432][i], 305, 65).has_point(pointer):
			hovered = i
	if event is InputEventMouseMotion:
		selected = hovered
		queue_redraw()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and hovered >= 0:
		$ClickSound.play()
		if hovered == 1:
			start_play()
		elif hovered == 2:
			var settings := preload("res://front end/audio_settings.tscn").instantiate()
			get_tree().root.add_child(settings)
		else:
			notice = "Disponible plus tard"
			queue_redraw()
