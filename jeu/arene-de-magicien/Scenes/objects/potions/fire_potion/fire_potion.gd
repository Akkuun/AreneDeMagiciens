@tool
extends XRToolsPickable

@onready var fire_explosion : PackedScene = load("res://Scenes/objects/potions/fire_potion/fire_explosion.tscn")

func _on_breaking_component_breaking(at: Vector3, speed: Vector3) -> void:
	var instance = fire_explosion.instantiate() as Node3D
	
	var previous_position = at + Vector3.UP
	
	instance.position = previous_position
	
	get_tree().get_nodes_in_group("root_3d").front().add_child(instance)
	queue_free()
