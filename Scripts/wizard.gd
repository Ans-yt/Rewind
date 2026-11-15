extends CharacterBody2D

@export var speed := 40.0
@export var gravity := 1500.0
@export var patrol_distance := 80.0
@export var detection_radius := 240.0
@export var attack_range := 130.0
@export var icon_spin_speed := 30.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var floor_check: RayCast2D = $FloorCheck
@onready var time_icon: Sprite2D = $TimeIcon

var player: Node2D = null
var start_x := 0.0
var direction := 1.0
var float_time := 0.0
var attack_time := 0.0
var attacking := false
var was_attacking := false
var sound_fade: Tween

func _ready() -> void:
	add_to_group("Wizards")
	start_x = global_position.x
	player = get_parent().get_node_or_null("Player")
	$CastSound.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	$CastSound.stream.loop_end = int($CastSound.stream.get_length() * $CastSound.stream.mix_rate)

func _physics_process(delta: float) -> void:
	float_time += delta
	if not is_on_floor():
		velocity.y += gravity * delta
	attacking = false
	if is_instance_valid(player) and global_position.distance_to(player.global_position) < detection_radius:
		var distance_x := player.global_position.x - global_position.x
		if absf(distance_x) > 1.0:
			direction = signf(distance_x)
		attacking = global_position.distance_to(player.global_position) <= attack_range
		velocity.x = 0.0 if attacking else direction * speed * 1.5
	else:
		if is_on_wall():
			direction *= -1.0
		if global_position.x >= start_x + patrol_distance:
			direction = -1.0
		elif global_position.x <= start_x - patrol_distance:
			direction = 1.0
		floor_check.position.x = direction * 24.0
		floor_check.force_raycast_update()
		if is_on_floor() and not floor_check.is_colliding():
			direction *= -1.0
		velocity.x = direction * speed
	move_and_slide()

	sprite.flip_h = direction > 0.0
	sprite.position.y = -8.0 + sin(float_time * 3.0) * 1.5
	if attacking:
		attack_time += delta
		sprite.frame = mini(int(attack_time / 0.1), 5) # il se prénomme tommie le mage
	else:
		attack_time = 0.0
		sprite.frame = 0
	time_icon.visible = attacking and sprite.frame >= 3
	time_icon.position = Vector2(direction * 38.0, sprite.position.y)
	if time_icon.visible:
		time_icon.rotation_degrees += icon_spin_speed * delta
	if attacking != was_attacking:
		if is_instance_valid(sound_fade):
			sound_fade.kill()
		sound_fade = create_tween()
		if attacking:
			if not $CastSound.playing:
				$CastSound.volume_db = -60.0
				$CastSound.play()
			sound_fade.tween_property($CastSound, "volume_db", -14.0, 0.12)
		else:
			sound_fade.tween_property($CastSound, "volume_db", -60.0, 0.18)
			sound_fade.tween_callback($CastSound.stop)
	was_attacking = attacking
