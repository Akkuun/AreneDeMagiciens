@tool
class_name InventorySlot extends XRToolsSnapZone

func connect_to_inventory_resource(inventory: InventoryComponent, index: int) -> void:
	connect("has_dropped", func ():
		inventory.drop_item(index)
		$Sprite3D.visible = true
	)

func set_item(item: XRToolsPickable):
	if(item.get_parent() == null):
		get_tree().get_nodes_in_group("root_3d").front().add_child(item)
	
	pick_up_object(item)
	$Sprite3D.visible = false

func hide_slot():
	visible = false
	if picked_up_object != null:
		picked_up_object.visible = false

func show_slot():
	visible = true
	if picked_up_object != null:
		picked_up_object.visible = true
