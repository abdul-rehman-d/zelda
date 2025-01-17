extends CharacterBody3D

#jump
@export var jump_height : float = 2.5
@export var jump_time_to_peak : float = 0.4
@export var jump_time_to_descent : float = 0.3

@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

@export var defend_speed := 3.0
@export var base_speed := 4.0
@export var run_speed := 6.0

@onready var camera = $CameraController/Camera3D
@onready var skin: Node3D = $GodetteSkin

var movement_input := Vector2.ZERO
var is_running := false
var is_defending := false:
	set(value):
		if not is_defending and value:
			skin.do_defend(value)
			is_defending = value
		elif is_defending and not value:
			skin.do_defend(value)
			is_defending = value


func _physics_process(delta: float) -> void:
	handle_movement(delta)
	handle_jump(delta)
	handle_attack(delta)
	move_and_slide()


func handle_attack(_delta: float) -> void:
	if Input.is_action_just_pressed("ability"):
		skin.play_attack_animation()
	
	is_defending = Input.is_action_pressed("block")


func handle_movement(delta: float) -> void:
	movement_input = Input.get_vector("left", "right", "forward", "backward")
	movement_input = movement_input.rotated(-camera.global_rotation.y)
	
	var speed = base_speed
	
	if Input.is_action_pressed("run"):
		speed = run_speed
	if is_defending:
		speed = defend_speed
	
	var vel_2d = Vector2(velocity.x, velocity.z)
	
	if movement_input != Vector2.ZERO:
		vel_2d += (movement_input * speed * delta)
		vel_2d = vel_2d.limit_length(speed)
		skin.set_move_state("Running")
		var target_angle = -movement_input.angle() + PI/2
		skin.rotation.y = rotate_toward(skin.rotation.y, target_angle, delta * 6.0)
	else:
		vel_2d = vel_2d.move_toward(Vector2.ZERO, base_speed * 4.0 * delta)
		skin.set_move_state("Idle")

	velocity.x = vel_2d.x
	velocity.z = vel_2d.y


func handle_jump(delta: float) -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_velocity
	
	if not is_on_floor():
		skin.set_move_state("Jump")
	
	velocity.y -= (get_gravity_local() * delta)


func get_gravity_local() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity
