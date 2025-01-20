extends Area3D

var direction: Vector2
const SPEED = 5.0

func _ready() -> void:
	scale = (Vector3.ONE * 0.1)

func _process(delta: float) -> void:
	position += (Vector3(direction.x, 0, direction.y) * SPEED * delta)


func setup(size: float) -> void:
	var tween = create_tween()
	tween.tween_property(self, 'scale', Vector3.ONE * size, 0.5)


func _on_body_entered(body: Node3D) -> void:
	if 'hit' in body:
		body.hit()
	queue_free()
