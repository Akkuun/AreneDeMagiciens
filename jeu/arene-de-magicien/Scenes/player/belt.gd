extends Node3D

@export var slot_count : int = 4

var spawn_path : Path3D
var path_follow : PathFollow3D
var inventory_slot_scene : PackedScene = load("res://Scenes/player/inventory_slot.tscn")


var slots : Array[InventorySlot]

func _ready() -> void:
	spawn_path = $SlotPath
	path_follow = $SlotPath/PathFollow3D
	for i in range(slot_count):
		var slot = inventory_slot_scene.instantiate() as InventorySlot
		path_follow.progress_ratio = i / float(slot_count-1)
		slot.position = path_follow.position
		add_child(slot)
		
		slot.connect_to_inventory_resource($Inventory, i)
		slots.append(slot)

func set_slot_item(item: XRToolsPickable, index: int):
	slots[index].set_item(item)


func set_visibility(state: bool):
	for slot in slots:
		if state:
			slot.show_slot()
		else:
			slot.hide_slot()
	
