extends Node3D

@export var min_value_x : float = 0.0
@export var max_value_x : float = 0.0
@export var mouse_camera_sensitivity := 0.005
@export var horizontal_acceleration := 2.0
@export var vertical_acceleration := 1.0

func _process(delta: float) -> void:
	var joystick_direction = Input.get_vector("pan_left", "pan_right", "pan_up", "pan_down")
	rotate_from_vector(joystick_direction * delta * Vector2(horizontal_acceleration, vertical_acceleration))

# TODO: make both work
#func _input(event: InputEvent) -> void:
	#if event is InputEventMouseMotion:
		#rotate_from_vector(event.relative * mouse_camera_sensitivity)
		#print(event.relative)

func rotate_from_vector(vec: Vector2) -> void:
	if vec.length() == 0:
		return
	rotation.y -= vec.x
	var x = rotation.x - vec.y
	rotation.x = clamp(x, min_value_x, max_value_x)
