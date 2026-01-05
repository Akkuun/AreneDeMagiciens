@tool
extends XRToolsPickable

@onready var healing_area : PackedScene = load("res://Scenes/objects/potions/heal_potion/heal_area.tscn")
func _on_breaking_component_breaking(at: Vector3, speed: Vector3) -> void:
	var instance := healing_area.instantiate() as Node3D
	instance.position = at + Vector3.UP * 0.1
	get_tree().get_nodes_in_group("root_3d").front().add_child(instance)
	queue_free()
