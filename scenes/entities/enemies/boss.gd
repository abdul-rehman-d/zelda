extends Enemy

var simple_attacks = {
	'slice': '2H_Melee_Attack_Slice',
	'spin': '2H_Melee_Attack_Spin',
	'range': '1H_Melee_Attack_Stab',
}

@export var spin_speed: float = 6.0

var spinning := false
var can_damage := false

signal cast_spell(type: String, pos: Vector3, direction: Vector2, size: float)


func _process(_delta: float) -> void:
	if can_damage:
		var collider = %AxeRayCast.get_collider()
		if collider and 'hit' in collider:
			collider.hit()


func _physics_process(delta: float) -> void:
	move_to_player(delta)


func _on_attack_timer_timeout() -> void:
	$Timers/AttackTimer.wait_time = rng.randf_range(4.0, 5.5)
	var dis = position.distance_to(player.position)
	
	if dis <= 5.0:
		melee_attack_animation()
	elif dis <= notice_radius:
		range_attack_animation()
		#if rng.randi() %2:
			#range_attack_animation()
		#else:
			#spin_attack_animation()


func spin_attack_animation() -> void:
	var tween = create_tween()
	tween.tween_property(self, 'speed', spin_speed, 0.5)
	tween.tween_method(_spin_transition, 0.0, 1.0, 0.3)
	$Timers/AttackTimer.stop()
	spinning = true
	can_damage = true


func _spin_transition(value: float) -> void:
	$AnimationTree.set("parameters/SpinBlend/blend_amount", value)


func melee_attack_animation() -> void:
	attack_animation.animation = simple_attacks['slice' if rng.randi() % 2 else 'spin']
	$AnimationTree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func range_attack_animation() -> void:
	stop_movement(1.6, 1.6)
	attack_animation.animation = simple_attacks['range']
	$AnimationTree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func _on_area_3d_body_entered(_body: Node3D) -> void:
	if spinning:
		await get_tree().create_timer(rng.randf_range(1.0, 2.0)).timeout
		var tween = create_tween()
		tween.tween_property(self, 'speed', walk_speed, 0.5)
		tween.tween_method(_spin_transition, 1.0, 0.0, 0.3)
		spinning = false
		can_damage = false
		$Timers/AttackTimer.start()


func hit() -> void:
	if not $Timers/InvulTimer.time_left:
		print("boss got hit")
		do_squash_and_stretch(1.15, 0.15)
		$Timers/InvulTimer.start()


func set_can_damage(value: bool) -> void:
	can_damage = value


func _shoot_fireball() -> void:
	var spawn_pos = %FireballSpawn.global_position
	cast_spell.emit("fireball", spawn_pos, last_movement, 3.0)
