extends Node3D


func _on_life_component_dead() -> void:
	queue_free()
