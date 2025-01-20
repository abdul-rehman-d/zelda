extends Enemy

@onready var bone: Node3D = $Skin/Rig/Skeleton3D/RightHandSlot/Bone

func _physics_process(delta: float) -> void:
	move_to_player(delta)


func _on_attack_timer_timeout() -> void:
	$Timers/AttackTimer.wait_time = rng.randf_range(2.5, 3.5)
	if position.distance_to(player.position) <= attack_radius:
		print(position.distance_to(player.position))
		$AnimationTree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func can_damage(value: bool) -> void:
	bone.can_damage = value
