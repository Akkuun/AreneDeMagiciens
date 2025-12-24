class_name InventoryComponent extends Node

var instantiated_items : Array[XRToolsPickable]
@export var inventory_resource : InventoryResource

signal inventory_item_instantiated(node: XRToolsPickable, position: int)

func _ready() -> void:
	inventory_resource.init()
	for i in range(inventory_resource.items.size()):
		instantiated_items.append(null)
		if(!inventory_resource.is_slot_free(i)):
			var instance = inventory_resource.items[i].instantiate() as XRToolsPickable
			instantiated_items[i] = instance
			call_deferred("emit_signal", "inventory_item_instantiated", instance, i)

func add_item(pickable: XRToolsPickable, position: int = -1) -> bool:
	if inventory_resource.is_full():
		return false
	
	if position < 0:
		for i in range(inventory_resource.items.size()):
			if(inventory_resource.is_slot_free(i)):
				inventory_resource.items[i] = load(pickable.scene_file_path)
				instantiated_items[i] = pickable
				call_deferred("emit_signal", "inventory_item_instantiated", pickable, i)
				return true
		return false
	else:
		inventory_resource.items[position] = load(pickable.scene_file_path)
		instantiated_items[position] = pickable
		call_deferred("emit_signal", "inventory_item_instantiated", pickable, position)
		return true

func get_item(index: int) -> XRToolsPickable:
	var result = instantiated_items[index]
	return result

func drop_item(index: int) -> void:
	inventory_resource.items[index] = null
	instantiated_items[index] = null
