extends Node3D

@export var width : int = 4
@export var slot_count : int = 8
@export var space_between : float = 1.0

var drop_slot_pckd_scene : PackedScene

@export var visu : BoxMesh

var drop_slots : Array[XRToolsSnapZone]

func _enter_tree() -> void:
	drop_slot_pckd_scene = load("res://addons/godot-xr-tools/objects/snap_zone.tscn")
	var offset : Vector3 = Vector3(-width, -slot_count/width, 0) * space_between * 0.5
	for i in range(slot_count):
		var y = int(i / width)
		var x = int(i % width)
		
		var drop_slot = drop_slot_pckd_scene.instantiate() as XRToolsSnapZone
		drop_slot.position.x = x * space_between
		drop_slot.position.y = y * space_between
		drop_slot.position += offset
		add_child(drop_slot)
		drop_slots.append(drop_slot)
		
		drop_slot.connect("has_dropped", func ():
			$Inventory.drop_item(i)
		)
		
		var mesh_visu := MeshInstance3D.new()
		mesh_visu.mesh = visu
		mesh_visu.position = drop_slot.position
		add_child(mesh_visu)

func set_slot_item(item: XRToolsPickable, index: int):
	drop_slots[index].pick_up(item)
	if(item.get_parent() == null):
		add_child(item)
	else:
		item.reparent(self)
