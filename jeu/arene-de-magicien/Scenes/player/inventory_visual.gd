extends Node3D

@export var width : int = 4
@export var slot_count : int = 8
@export var space_between : float = 1.0

var drop_slot_pckd_scene : PackedScene

@export var visu : BoxMesh

var drop_slots : Array[XRToolsSnapZone]

func _enter_tree() -> void:
	drop_slot_pckd_scene = load("res://addons/godot-xr-tools/objects/snap_zone.tscn")
	
	var height_count = round(slot_count/width)
	var offset : Vector3 = Vector3(-(width - 1) * 0.5, height_count, 0) * space_between
	for i in range(slot_count):
		var y = i / width
		var x = int(i % width)
		
		var drop_slot = drop_slot_pckd_scene.instantiate() as XRToolsSnapZone
		drop_slot.position.x = x * space_between
		drop_slot.position.y = -y * space_between
		drop_slot.position += offset
		add_child(drop_slot)
		drop_slots.append(drop_slot)
		
		drop_slot.connect("has_dropped", func ():
			$Inventory.restore_item_size(i)
			$Inventory.drop_item(i)
		)
		
		var mesh_visu := MeshInstance3D.new()
		mesh_visu.mesh = visu
		mesh_visu.position = drop_slot.position
		add_child(mesh_visu)
	
	$Inventory.connect("inventory_item_instantiated", set_slot_item)

func set_slot_item(item: XRToolsPickable, index: int):
	drop_slots[index].pick_up_object(item)
	#item.pick_up(drop_slots[index])
	if(item.get_parent() == null):
		add_child(item)
	else:
		item.reparent(self)
	
	if item.has_node("MeshInstance3D"):
		item.get_node("MeshInstance3D").scale = Vector3(0.3, 0.3, 0.3)
	
