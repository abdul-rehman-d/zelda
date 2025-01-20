extends Node3D

@onready var ray_cast: RayCast3D = $RayCast3D

var can_damage := false

func _process(_delta: float) -> void:
	if can_damage:
		var collider := ray_cast.get_collider()
		if collider and 'hit' in collider:
			collider.hit()
