class_name InventoryResource extends Resource

@export var items : Array[PackedScene]
@export var max_size : int = 8

func _init() -> void:
	var missing_slots = max_size - items.size()
	for i in range(missing_slots):
		items.append(null)

func is_full() -> bool:
	for item in items:
		if item == null:
			return false
	return true

func clear(slot_index):
	items[slot_index] = null

func is_slot_free(slot_index: int) -> bool:
	return items[slot_index] == null

func set_slot(slot_index: int, item: PackedScene):
	items[slot_index] = item
