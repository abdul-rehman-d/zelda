extends Node3D

var Fireball_Scene: PackedScene = preload("res://scenes/vfx/fireball.tscn")

func _ready() -> void:
	for entity in $Entities.get_children():
		if entity.has_signal('cast_spell'):
			entity.connect('cast_spell', spawn_fireball)

func spawn_fireball(type: String, pos: Vector3, direction: Vector2, size: float) -> void:
	var fireball = Fireball_Scene.instantiate()
	fireball.global_position = pos
	fireball.direction = direction
	fireball.setup(size)
	$Projectiles.add_child(fireball)


#func _on_player_cast_spell(type: String, pos: Vector3, direction: Vector2, size: float) -> void:
	#spawn_fireball(type, pos, direction, size)
#
#
#func _on_mage_cast_spell(type: String, pos: Vector3, direction: Vector2, size: float) -> void:
	#spawn_fireball(type, pos, direction, size)
#
#
#func _on_boss_cast_spell(type: String, pos: Vector3, direction: Vector2, size: float) -> void:
	#spawn_fireball(type, pos, direction, size)
