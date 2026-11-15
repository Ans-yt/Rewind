extends "res://Scripts/wizard.gd"
## The existing wizard, with ledge safety and a dash counter for level 3.
var stun_left := 0.0

func _physics_process(delta: float) -> void:
	if stun_left > 0.0:
		stun_left -= delta
		attacking = false
		time_icon.hide()
		$CastSound.stop()
		modulate = Color("70edd2")
		return
	modulate = Color.WHITE
	# Check the next step while chasing, as well as while patrolling.
	if is_instance_valid(player):
		floor_check.position.x = signf(player.global_position.x - global_position.x) * 24.0
		floor_check.force_raycast_update()
		if is_on_floor() and not floor_check.is_colliding():
			var saved_radius := detection_radius
			detection_radius = 0.0
			super._physics_process(delta)
			detection_radius = saved_radius
		else:
			super._physics_process(delta)
	else:
		super._physics_process(delta)
	if not is_instance_valid(player) or not player.is_rewinding:
		return
	var player_center: Vector2 = player.global_position + Vector2(0, 46.5)
	if global_position.distance_to(player_center) < 34.0:
		if not player.dashCooldown.is_stopped():
			stun_left = 3.0
			attacking = false
			time_icon.hide()
			$CastSound.stop()
		else:
			get_parent().take_hit()
