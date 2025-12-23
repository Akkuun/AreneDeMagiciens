@tool
extends XRToolsPickable


func _on_grabbed(pickable: Variant, by: Variant) -> void:
	$InventoryVisual.hide_content()


func _on_dropped(pickable: Variant) -> void:
	$InventoryVisual.show_content()

func hide_content():
	$InventoryVisual.visible = false
	


func _on_harvest_area_body_entered(body: Node3D) -> void:
	if body is XRToolsPickable and body != self:
		$InventoryVisual/Inventory.add_item(body)
