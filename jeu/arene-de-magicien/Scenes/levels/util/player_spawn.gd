extends Node3D

func _ready() -> void:
	var player = get_tree().get_nodes_in_group("player").front()
	player.global_position = global_position
	player.global_rotation = global_rotation
