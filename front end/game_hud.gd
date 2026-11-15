extends Control

const WOOD = preload("res://front end/assets/wooden_ui.png")
const KEYS = preload("res://front end/assets/keys.png")
const FONT = preload("res://front end/assets/Lockergnome.otf")

var tutorial_font: FontFile = preload("res://front end/assets/PixelifySans.ttf")
var panel := StyleBoxTexture.new()
var labels := ["Jump", "Left", "Right", "Rewind", "Dash"]
var key_regions := [Rect2(16, 112, 16, 16), Rect2(48, 112, 16, 16), Rect2(64, 112, 16, 16), Rect2(0, 112, 16, 16), Rect2(80, 96, 16, 16)]

func _ready() -> void:
	preload("res://front end/music.gd").start(get_tree())
	panel.texture = WOOD
	panel.region_rect = Rect2(448, 640, 96, 96)
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		panel.set_texture_margin(side, 8)
	$Settings.pressed.connect(show_settings)
	$Restart.pressed.connect(restart_level)
	resized.connect(queue_redraw)
	tutorial_font.antialiasing = TextServer.FONT_ANTIALIASING_NONE
	tutorial_font.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	var level := get_parent().get_parent()
	for label_name in ["tuto1", "tuto2", "tuto3", "tuto4"]:
		var label: Label = level.get_node(label_name)
		var settings: LabelSettings = label.label_settings.duplicate()
		settings.font = tutorial_font
		settings.font_color = Color.WHITE
		settings.outline_color = Color.BLACK
		settings.outline_size = 8
		label.label_settings = settings

func _draw() -> void:
	var top := size.y - 214.0
	draw_style_box(panel, Rect2(16, top, 178, 198))
	draw_label(Vector2(34, top + 28), "CONTROLS", 18)
	for i in range(5):
		var y := top + 40 + i * 29
		draw_texture_rect_region(KEYS, Rect2(30, y, 28, 28), key_regions[i])
		if i == 3:
			draw_string(ThemeDB.fallback_font, Vector2(31, y + 17), "SPACE", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("292623"))
		draw_label(Vector2(68, y + 20), labels[i], 18)

func draw_label(point: Vector2, text: String, font_size: int) -> void:
	draw_string_outline(FONT, point, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, 3, Color("30201c"))
	draw_string(FONT, point, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color("fff0c4"))

func show_settings() -> void:
	$ClickSound.play()
	var settings := preload("res://front end/audio_settings.tscn").instantiate()
	get_tree().root.add_child(settings)

func restart_level() -> void:
	var click := $ClickSound
	click.reparent(get_tree().root)
	click.finished.connect(click.queue_free)
	click.play()
	get_tree().reload_current_scene()
