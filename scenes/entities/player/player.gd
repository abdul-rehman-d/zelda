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

@onready var camera: Camera3D = $CameraController/Camera3D
@onready var skin: Node3D = $GodetteSkin

enum WEAPON {SWORD, WAND}
var selected_weapon: WEAPON = WEAPON.SWORD

var movement_input := Vector2.ZERO
var is_running := false
var speed_modifier := 1.0
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
	handle_attack()
	handle_weapon_stuff()
	
	if Input.is_action_just_pressed("ui_accept"):
		handle_hit()
	
	move_and_slide()


func handle_attack() -> void:
	if Input.is_action_just_pressed("ability"):
		if not skin.is_attacking:
			match selected_weapon:
				WEAPON.SWORD:
					skin.play_attack_animation()
				WEAPON.WAND:
					skin.play_spell_animation()
					stop_movement(0.3, 0.8)
	
	is_defending = Input.is_action_pressed("block")


func handle_weapon_stuff() -> void:
	if Input.is_action_just_pressed("switch weapon") and not skin.is_attacking:
		match selected_weapon:
			WEAPON.SWORD:
				selected_weapon = WEAPON.WAND
				skin.sword.hide()
				skin.wand.show()
			WEAPON.WAND:
				selected_weapon = WEAPON.SWORD
				skin.sword.show()
				skin.wand.hide()
		do_squash_and_stretch(1.1, 0.15)


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
		vel_2d += (movement_input * speed * delta * 8.0)
		vel_2d = vel_2d.limit_length(speed) * speed_modifier
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
		do_squash_and_stretch(1.2, 0.15)
	
	if not is_on_floor():
		skin.set_move_state("Jump")
	
	velocity.y -= (get_gravity_local() * delta)


func handle_hit() -> void:
	skin.hit()
	stop_movement(0.3, 0.8)


func do_squash_and_stretch(value: float, duration: float = 0.1) -> void:
	var tween = create_tween()
	tween.tween_property(skin, "squash_and_strech", value, duration)
	tween.tween_property(skin, "squash_and_strech", 1.0, duration * 1.8).set_ease(Tween.EASE_OUT)


func stop_movement(start_duration: float, end_duration: float) -> void:
	var tween = create_tween()
	tween.tween_property(self, "speed_modifier", 0.0, start_duration)
	tween.tween_property(self, "speed_modifier", 1.0, end_duration)


func get_gravity_local() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity
