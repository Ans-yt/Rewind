extends Node

@onready var player = get_parent()
@onready var tiles: TileMapLayer = player.get_parent().get_node("TilemapSol")

var was_rewinding := false
var was_on_floor := false
var dash_was_ready := true
var previous_fall_speed := 0.0
var step_time := 0.0
var was_in_water := false

func _ready() -> void:
	process_physics_priority = 1
	$Rewind.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	$Rewind.stream.loop_end = int($Rewind.stream.get_length() * $Rewind.stream.mix_rate)

func _physics_process(delta: float) -> void:
	var rewinding: bool = Input.is_action_pressed("rewind") and not player.is_rewinding and player.positionsX.size() == player.MAX_HISTORY and player.i > 0 and player.i <= player.r + 1
	if rewinding and not was_rewinding:
		$RewindEnd.stop()
		$Rewind.play()
	elif not rewinding and was_rewinding:
		$Rewind.stop()
		if not Input.is_action_pressed("Respawn"):
			$RewindEnd.play()
	var on_floor: bool = player.is_on_floor()
	var feet: Vector2 = player.get_node("CollisionShape2D").global_position + Vector2(0, 16)
	var tile := tiles.get_cell_atlas_coords(tiles.local_to_map(tiles.to_local(feet)))
	var in_water := tile == Vector2i(9, 2) or tile == Vector2i(10, 2)
	if not rewinding:
		if in_water and not was_in_water and not Input.is_action_pressed("Respawn"):
			$Splash.play()
			$Step.stop()
			$Landing.stop()
		if on_floor and not was_on_floor and previous_fall_speed > 120.0 and not in_water:
			$Landing.play()
		if dash_was_ready and not player.dashCooldown.is_stopped() and Input.get_axis("move_left", "move_right") != 0.0:
			$Dash.play()
		step_time -= delta
		if on_floor and absf(player.velocity.x) > 30.0 and step_time <= 0.0:
			if in_water:
				$WaterStep.play()
			else:
				$Step.play()
			step_time = 0.32
	else:
		$Step.stop()
		$Landing.stop()
		$WaterStep.stop()
		$Splash.stop()
	was_rewinding = rewinding
	was_on_floor = on_floor
	previous_fall_speed = player.velocity.y
	dash_was_ready = player.dashCooldown.is_stopped()
	was_in_water = in_water
