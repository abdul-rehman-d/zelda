class_name Enemy
extends CharacterBody3D

@onready var player: CharacterBody3D = get_tree().get_first_node_in_group('Player')
@onready var skin: Node3D = get_node('Skin')
@onready var attack_animation: AnimationNodeAnimation = $AnimationTree.get_tree_root().get_node("AttackAnimation")
@onready var move_state_machine = $AnimationTree.get("parameters/MoveStateMachine/playback")

@export var walk_speed: float = 3.0
@onready var speed = walk_speed
@export var notice_radius: float = 30.0
@export var attack_radius: float = 3.0

var rng = RandomNumberGenerator.new()
var speed_modifier = 1.0

func move_to_player(delta: float) -> void:
	var target_pos = (player.position - position).normalized()
	
	var dis = position.distance_to(player.position)
	
	if dis <= notice_radius:
		# CHASE
		var move_direction = Vector2(target_pos.x, target_pos.z)
		var target_angle = -move_direction.angle() + PI/2
		rotation.y = rotate_toward(rotation.y, target_angle, delta * 6.0)
		
		if dis <= attack_radius:
			velocity = Vector3.ZERO
			move_state_machine.travel("Idle")
		else:
			move_state_machine.travel("Running")
			velocity.x = move_direction.x * speed * speed_modifier
			velocity.z = move_direction.y * speed * speed_modifier
	else:
		# IDLE
		move_state_machine.travel("Idle")
		velocity.x = 0
		velocity.z = 0
	
	move_and_slide()


func stop_movement(start_duration: float, end_duration: float) -> void:
	var tween = create_tween()
	tween.tween_property(self, "speed_modifier", 0.0, start_duration)
	tween.tween_property(self, "speed_modifier", 1.0, end_duration)
