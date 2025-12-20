@tool
class_name InventorySlot extends XRToolsSnapZone

func connect_to_inventory_resource(inventory: InventoryResource, index: int) -> void:
	connect("has_dropped", func ():
		inventory.restore_item_size(index)
		inventory.drop_item(index)
		$Sprite3D.visible = true
	)

func set_item(item: XRToolsPickable):
	if(item.get_parent() == null):
		add_child(item)
	
	pick_up_object(item)
	$Sprite3D.visible = false
	
	if item.has_node("MeshInstance3D"):
		item.get_node("MeshInstance3D").scale = Vector3(0.3, 0.3, 0.3)
