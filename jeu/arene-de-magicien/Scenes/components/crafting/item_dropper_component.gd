extends Node3D

@export var item_to_drop : PackedScene

signal item_instanciated(item: Node)

func drop():
	var instance = item_to_drop.instantiate()
	var root_node = get_tree().get_nodes_in_group("root_3d").front()
	if root_node == null:
		add_child(instance)
	else:
		root_node.add_child(instance)
	
	item_instanciated.emit(instance)
