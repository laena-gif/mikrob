extends Node

@export var EnemyScene: PackedScene
@export var spawn_position: Marker3D

func _on_body_entered(body: Node3D) -> void:
	spawn_enemy()
	
func spawn_enemy():
	var enemy = EnemyScene.instantiate()
	enemy.position = spawn_position
	get_tree().current_scene.add_child(enemy)
