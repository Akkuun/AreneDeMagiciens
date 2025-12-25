extends Node3D


func _on_duration_timeout() -> void:
	queue_free()
