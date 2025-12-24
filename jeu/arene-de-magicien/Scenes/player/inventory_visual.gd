extends Node3D

@export var width : int = 4
@export var slot_count : int = 8
@export var space_between : float = 1.0

var drop_slot_pckd_scene : PackedScene = load("res://Scenes/player/inventory_slot.tscn")

var drop_slots : Array[InventorySlot]

func _ready() -> void:	
	var height_count = round(slot_count/width)
	var offset : Vector3 = Vector3(-(width - 1) * 0.5, height_count, 0) * space_between
	for i in range(slot_count):
		var y = i / width
		var x = int(i % width)
		
		var drop_slot = drop_slot_pckd_scene.instantiate() as InventorySlot
		drop_slot.position.x = x * space_between
		drop_slot.position.y = -y * space_between
		drop_slot.position += offset
		add_child(drop_slot)
		drop_slot.connect_to_inventory_resource($Inventory, i)
		drop_slots.append(drop_slot)
		

func set_slot_item(item: XRToolsPickable, index: int):
	drop_slots[index].set_item(item)
	

func hide_content():
	for slot in drop_slots:
		slot.hide_slot()

func show_content():
	for slot in drop_slots:
		slot.show_slot()
