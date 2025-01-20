extends Enemy

signal cast_spell(type: String, pos: Vector3, direction: Vector2, size: float)


func _physics_process(delta: float) -> void:
	move_to_player(delta)


func _on_attack_timer_timeout() -> void:
	$Timers/AttackTimer.wait_time = rng.randf_range(2.0, 3.5)
	if position.distance_to(player.position) <= attack_radius:
		$AnimationTree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func _shoot_fireball() -> void:
	var spawn_pos = %FireballSpawn.global_position
	cast_spell.emit("fireball", spawn_pos, last_movement, 1.0)
